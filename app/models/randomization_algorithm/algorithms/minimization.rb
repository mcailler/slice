module RandomizationAlgorithm

  module Algorithms

    class Minimization < Default

      attr_reader :randomization_scheme

      def initialize(randomization_scheme)
        @randomization_scheme = randomization_scheme
      end

      # def randomization_error_message
      #   "Treatment Arms may not be set up correctly."
      # end

      def add_missing_lists!(current_user)
        if @randomization_scheme.lists.count == 0 and self.number_of_lists > 0 and self.number_of_lists < RandomizationScheme::MAX_LISTS
          @randomization_scheme.lists.create(project_id: @randomization_scheme.project_id, user_id: current_user.id)
        end
      end

      # def number_of_lists
      #   1
      # end

      # def find_list_by_option_hashes(option_hashes)
      #   criteria_pairs = option_hashes.collect{|h| [h[:stratification_factor_id], (h[:stratification_factor_option_id] || h[:site_id])]}
      #   self.find_list_by_criteria_pairs(criteria_pairs)
      # end

      # def find_list_by_criteria_pairs(criteria_pairs)
      #   @randomization_scheme.lists.first
      # end

      def randomize_subject_to_list!(subject, list, current_user, criteria_pairs)
        # Remove any blank randomizations
        list.randomizations.where(subject_id: nil).destroy_all

        # Create a dynamic randomization
        randomization = self.generate_next_randomization!(list, current_user, criteria_pairs)

        # Add subject to randomization list
        randomization.add_subject!(subject, current_user) if randomization
        randomization
      end

      protected

        def generate_next_randomization!(list, current_user, criteria_pairs)
          criteria_pairs.collect!{|sfid,oid| [sfid.to_i, oid.to_i]}

          @randomization_scheme.stratification_factors.each do |sf|
            unless criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
              # Return if not all criteria pairs are selected
              return nil
            end
          end

          notes = []

          # "Randomly selected treatment arm {X}"
          # "Selected Least full treatment arm {X} based on Criteria {Y,Z}"
          # "Randomly Selected least full treatment arm {X} from possible options {K,L,X} based on Criteria {Y,Z}".

          # If 30% chance, select random treatment arm
          notes << "**Is treatment arm selection random?**"
          dice_roll = rand(100)
          dice_roll_cutoff = @randomization_scheme.chance_for_random_selection
          past_distributions = {}
          weighted_eligible_arms = nil

          if dice_roll < dice_roll_cutoff
            notes << "Yes, ==#{dice_roll}== is less than #{dice_roll_cutoff}."
            (treatment_arm, new_notes, weighted_eligible_arms) = select_random_treatment_arm
            notes += new_notes
          else
            notes << "No, ==#{dice_roll}== is greater than or equal to #{dice_roll_cutoff}."
            (treatment_arm, new_notes, weighted_eligible_arms, past_distributions) = get_treatment_arm(list, criteria_pairs)
            notes += new_notes
          end

          randomization = nil

          if treatment_arm and weighted_eligible_arms.kind_of?(Array)
            randomization = list.randomizations.create(
              project_id: @randomization_scheme.project_id,
              randomization_scheme_id: @randomization_scheme.id,
              user_id: current_user.id,
              treatment_arm_id: treatment_arm.id,
              notes: notes.join("\n\n"),
              dice_roll: dice_roll,
              dice_roll_cutoff: dice_roll_cutoff,
              past_distributions: past_distributions,
              weighted_eligible_arms: weighted_eligible_arms.collect{ |arm| { name: arm.name, id: arm.id } }.sort{|a,b| a[:name] <=> b[:name]}
            )
            @randomization_scheme.stratification_factors.each do |sf|
              if criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
                if sf.stratifies_by_site?
                  randomization.randomization_characteristics.create(
                    project_id: @randomization_scheme.project_id,
                    randomization_scheme_id: @randomization_scheme.id,
                    list_id: randomization.list_id,
                    stratification_factor_id: sf.id,
                    site_id: @randomization_scheme.project.sites.where(id: criteria.last).pluck(:id).first
                  )
                else
                  randomization.randomization_characteristics.create(
                    project_id: @randomization_scheme.project_id,
                    randomization_scheme_id: @randomization_scheme.id,
                    list_id: randomization.list_id,
                    stratification_factor_id: sf.id,
                    stratification_factor_option_id: sf.stratification_factor_options.where(id: criteria.last).pluck(:id).first
                  )
                end
              end
            end
          end

          randomization
        end

        def get_treatment_arm(list, criteria_pairs)
          all_criteria_selected = true
          past_distributions = {}

          notes = []

          notes << "**Select Treatment Arm Based on Criteria Distributions**"

          randomization_scope = list.randomizations
          treatment_arms_and_counts = []

          stratification_factor_counts = {}
          @randomization_scheme.stratification_factors.each do |sf|
            if criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
              stratification_factor_counts[criteria.join('x')] ||= {}
              if sf.stratifies_by_site?
                site = @randomization_scheme.project.sites.find_by_id(criteria.last)
                stratification_factor_counts[criteria.join('x')][:name] = site.name if site
              else
                sfo = @randomization_scheme.stratification_factor_options.find_by_id(criteria.last)
                stratification_factor_counts[criteria.join('x')][:name] = sfo.label if sfo
              end
            end
          end

          @randomization_scheme.treatment_arms.positive_allocation.order(:name).each do |treatment_arm|
            randomization_ids = []
            @randomization_scheme.stratification_factors.each do |sf|
              unless criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
                all_criteria_selected = false
              end

              if criteria
                criteria_randomization_ids = if sf.stratifies_by_site?
                  list.randomizations.includes(:randomization_characteristics).where.not(subject_id: nil).where(treatment_arm_id: treatment_arm.id).where(randomization_characteristics: { site_id: criteria.last }).pluck(:id)
                else
                  list.randomizations.includes(:randomization_characteristics).where.not(subject_id: nil).where(treatment_arm_id: treatment_arm.id).where(randomization_characteristics: { stratification_factor_option_id: criteria.last }).pluck(:id)
                end
                stratification_factor_counts[criteria.join('x')][treatment_arm.id.to_s] = criteria_randomization_ids.count
                randomization_ids += criteria_randomization_ids
              end

            end
            treatment_arms_and_counts << [treatment_arm, randomization_ids.count]
          end

          # Arms should be weighted by their allocation
          # An arm with 0 current randomizations, and a zero allocation, should be set at Infinity
          # An allocation of zero would make it never get selected if other treatment arms have a positive allocation

          weighted_treatment_arms_and_counts = treatment_arms_and_counts.collect{|arm, count| [arm, count == 0 ? 0 : (count / arm.allocation.to_f)]}


          past_distributions[:treatment_arms] = @randomization_scheme.treatment_arms.positive_allocation.order(:name).collect{ |arm| { name: arm.name, id: arm.id } }
          # Draw Table
          table = []
          table << "| Stratification Factor | #{@randomization_scheme.treatment_arms.collect(&:name).join(' | ')} |"
          table << "|:----|#{"----:|"*@randomization_scheme.treatment_arms.count}"

          past_distributions[:stratification_factors] = []

          @randomization_scheme.stratification_factors.each do |sf|
            sf_hash = {}
            if criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
              name = stratification_factor_counts[criteria.join('x')][:name]
              sf_hash[:name] = name
              sf_hash[:criteria] = criteria
              sf_hash[:treatment_arm_counts] = []
              row = "|#{name}|"
              @randomization_scheme.treatment_arms.positive_allocation.order(:name).each do |treatment_arm|
                count = stratification_factor_counts[criteria.join('x')][treatment_arm.id.to_s]
                sf_hash[:treatment_arm_counts] << { count: count, treatment_arm_id: treatment_arm.id }
                row += "#{count}|"
              end

              table << row
            end
            past_distributions[:stratification_factors] << sf_hash
          end

          past_distributions[:totals] = treatment_arms_and_counts.collect{|arm, count| { count: count, treatment_arm_id: arm.id } }
          past_distributions[:weighted_totals] = weighted_treatment_arms_and_counts.collect{|arm, count| { count: count.round(2), treatment_arm_id: arm.id } }

          table << "|**Total**|#{treatment_arms_and_counts.collect(&:last).join(' | ')} |"
          table << "|**Weighted Total**|#{weighted_treatment_arms_and_counts.collect{|a| a.last.round(2)}.join(' | ')} |"
          notes << table.join("\n")
          # End Draw Table

          treatment_arm = nil
          weighted_eligible_arms = nil

          if all_criteria_selected
            min_value = weighted_treatment_arms_and_counts.collect{|arm, count| count}.min
            eligible_arms = weighted_treatment_arms_and_counts.select{|arm, count| count == min_value}.collect{|arm, count| arm}
            (treatment_arm, new_notes, weighted_eligible_arms) = randomly_select_eligible_treatment_arm(eligible_arms)
            notes += new_notes
          end

          [treatment_arm, notes, weighted_eligible_arms, past_distributions]
        end

        def select_random_treatment_arm
          notes = []
          notes << "**Randomly Select Treatment Arm**"
          eligible_arms = @randomization_scheme.treatment_arms.positive_allocation
          (treatment_arm, new_notes, weighted_eligible_arms) = randomly_select_eligible_treatment_arm(eligible_arms)
          notes += new_notes
          [treatment_arm, notes, weighted_eligible_arms]
        end

        def randomly_select_eligible_treatment_arm(eligible_arms)
          weighted_eligible_arms = eligible_arms.collect{|arm| [arm]*arm.allocation}.flatten
          notes = []
          notes << "Weighted Eligible Arms: [#{weighted_eligible_arms.collect(&:name).sort.join(', ')}]" if weighted_eligible_arms.uniq.count > 1
          treatment_arm = weighted_eligible_arms[rand(weighted_eligible_arms.count)]
          notes << "==#{treatment_arm.name}== selected." if treatment_arm
          [treatment_arm, notes, weighted_eligible_arms]
        end
    end

  end

end

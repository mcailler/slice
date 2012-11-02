class Domain < ActiveRecord::Base
  attr_accessible :name, :description, :options, :option_tokens, :project_id, :user_id

  serialize :options, Array

  before_save :check_option_validations

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :variables, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_column :deleted, true
  end

  def variable_ids
    variable_ids = self.new_record? ? [] : self.variables.pluck(:id)
  end

  def sheet_variables
    SheetVariable.where(variable_id: self.variables.pluck(:id))
  end

  def grids
    Grid.where(variable_id: self.variables.pluck(:id))
  end

  # We want all validations to run so all errors will show up when submitting a form
  def check_option_validations
    result_a = check_for_colons
    result_b = check_value_uniqueness
    result_c = check_for_blank_values

    result_a and result_b and result_c
  end

  def check_for_colons
    result = true
    option_values = self.options.collect{|option| option[:value]}
    if option_values.join('').count(':') > 0
      self.errors.add(:option, "values can't contain colons" )
      result = false
    end
    result
  end

  def check_value_uniqueness
    result = true
    option_values = self.options.collect{|option| option[:value]}
    if option_values.uniq.size < option_values.size
      self.errors.add(:option, "values must be unique" )
      result = false
    end
    result
  end

  def check_for_blank_values
    result = true
    option_values = self.options.collect{|option| option[:value]}
    if option_values.select{|opt| opt.to_s.strip.blank?}.size > 0
      self.errors.add(:option, "values can't be blank" )
      result = false
    end
    result
  end

  # All of these changes are rolled back if the sheet is not saved successfully
  # Wrapped in single transaction
  def option_tokens=(tokens)
    unless self.new_record?
      original_options = self.options
      existing_options = tokens.reject{|key, hash| ['new', nil].include?(hash[:option_index]) }

      # Reset any sheets that specified an option that has been removed
      original_options.each_with_index do |hash, index|
        unless existing_options.collect{|key, hash| hash[:option_index].to_i}.include?(index)
          self.sheet_variables.where(response: hash.symbolize_keys[:value]).update_all(response: nil)
          self.grids.where(response: hash.symbolize_keys[:value]).update_all(response: nil)
        end
      end

      # Update all existing sheets to intermediate value for values that already existed and have changed
      existing_options.each_pair do |key, hash|
        old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
        new_value = hash[:value].strip
        if old_value != new_value
          intermediate_value = old_value + ":" + new_value
          self.sheet_variables.where(response: old_value).update_all(response: intermediate_value)
          self.grids.where(response: old_value).update_all(response: intermediate_value)
        end
      end

      # Update all existing sheets to new value
      existing_options.each_pair do |key, hash|
        old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
        new_value = hash[:value].strip
        if old_value != new_value
          intermediate_value = old_value + ":" + new_value
          self.sheet_variables.where(response: intermediate_value).update_all(response: new_value)
          self.grids.where(response: intermediate_value).update_all(response: new_value)
        end
      end
    end

    self.options = []
    tokens.each_pair do |key, option_hash|
      self.options << { name: option_hash[:name].strip,
                        value: option_hash[:value].strip,
                        description: option_hash[:description].strip,
                        missing_code: option_hash[:missing_code].to_s.strip,
                        color: option_hash[:color].to_s.strip.blank? ? '#ffffff' : option_hash[:color]
                      } unless option_hash[:name].strip.blank?
    end
  end


end
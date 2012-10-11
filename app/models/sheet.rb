class Sheet < ActiveRecord::Base
  attr_accessible :design_id, :project_id, :study_date, :subject_id, :variable_ids, :last_user_id

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :search, lambda { |*args| { conditions: [ 'subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?) or design_id in (select designs.id from designs where designs.deleted = ? and LOWER(designs.name) LIKE ?)', false, '%' + args.first.downcase.split(' ').join('%') + '%', false, '%' + args.first.downcase.split(' ').join('%') + '%'  ] } }
  scope :sheet_before, lambda { |*args| { conditions: ["sheets.study_date < ?", (args.first+1.day)]} }
  scope :sheet_after, lambda { |*args| { conditions: ["sheets.study_date >= ?", args.first]} }
  scope :with_user, lambda { |*args| { conditions: ["sheets.user_id in (?)", args.first] } }
  scope :with_project, lambda { |*args| { conditions: ["sheets.project_id IN (?)", args.first] } }
  scope :with_design, lambda { |*args| { conditions: ["sheets.design_id IN (?)", args.first] } }
  scope :with_site, lambda { |*args| { conditions: ["sheets.subject_id IN (select subjects.id from subjects where subjects.deleted = ? and subjects.site_id IN (?))", false, args.first] } }

  scope :with_variable_response, lambda { |*args| { conditions: ["sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response = ?)", args.first, args[1]] } }

  # These don't include blank codes
  scope :with_variable_response_after, lambda { |*args| { conditions: ["sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response >= ? and sheet_variables.response != '')", args.first, args[1]] } }
  scope :with_variable_response_before, lambda { |*args| { conditions: ["sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response <= ? and sheet_variables.response != '')", args.first, args[1]] } }

  # These include blank or missing responses
  scope :with_variable_response_after_with_blank, lambda { |*args| { conditions: ["sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response < ? and sheet_variables.response != '')", args.first, args[1]] } }
  scope :with_variable_response_before_with_blank, lambda { |*args| { conditions: ["sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response > ? and sheet_variables.response != '')", args.first, args[1]] } }

  # Only includes blank or unknown values
  scope :without_variable_response, lambda { |*args| { conditions: ["sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '')", args.first] } }
  # Includes entered values, or entered missing values
  scope :with_any_variable_response, lambda { |*args| { conditions: ["sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '')", args.first] } }
  # Includes only entered values (that are not marked as missing)
  scope :with_any_variable_response_not_missing_code, lambda { |*args| { conditions: ["sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)] } }
  # Include blank, unknown, or values entered as missing
  scope :with_response_unknown_or_missing, lambda { |*args| { conditions: ["sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)] } }

  # scope :last_entry, lambda { |*args| { conditions: ["sheets.id IN (SELECT s1.* FROM `sheets` s1 LEFT JOIN `sheets` s2 ON (s1.subject_id = s2.subject_id AND s1.study_date < s2.study_date) WHERE s2.id IS NULL)"] } }
  # scope :first_entry, lambda { |*args| { conditions: ["sheets.id IN (SELECT s1.* FROM `sheets` s1 LEFT JOIN `sheets` s2 ON (s1.subject_id = s2.subject_id AND s1.study_date > s2.study_date) WHERE s2.id IS NULL)"] } }

  scope :order_by_site_name, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id LEFT JOIN sites ON sites.id = subjects.site_id", order: 'sites.name' } }
  scope :order_by_site_name_desc, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id LEFT JOIN sites ON sites.id = subjects.site_id", order: 'sites.name DESC' } }

  scope :order_by_design_name, lambda { |*args| { joins: "LEFT JOIN designs ON designs.id = sheets.design_id", order: 'designs.name' } }
  scope :order_by_design_name_desc, lambda { |*args| { joins: "LEFT JOIN designs ON designs.id = sheets.design_id", order: 'designs.name DESC' } }

  scope :order_by_subject_code, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id", order: 'subjects.subject_code' } }
  scope :order_by_subject_code_desc, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id", order: 'subjects.subject_code DESC' } }

  scope :order_by_project_name, lambda { |*args| { joins: "LEFT JOIN projects ON projects.id = sheets.project_id", order: 'projects.name' } }
  scope :order_by_project_name_desc, lambda { |*args| { joins: "LEFT JOIN projects ON projects.id = sheets.project_id", order: 'projects.name DESC' } }

  scope :order_by_user_name, lambda { |*args| { joins: "LEFT JOIN users ON users.id = sheets.user_id", order: 'users.last_name, users.first_name' } }
  scope :order_by_user_name_desc, lambda { |*args| { joins: "LEFT JOIN users ON users.id = sheets.user_id", order: 'users.last_name DESC, users.first_name DESC' } }

  # Model Validation
  validates_presence_of :design_id, :project_id, :study_date, :subject_id, :user_id, :last_user_id
  validates_uniqueness_of :study_date, scope: [:project_id, :subject_id, :design_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :last_user, class_name: "User"
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  has_many :sheet_variables
  has_many :variables, through: :sheet_variables, conditions: { deleted: false }
  has_many :sheet_emails, conditions: { deleted: false }

  # Model Methods
  def self.last_entry
    self.scoped().joins("LEFT JOIN sheets s2 ON sheets.subject_id = s2.subject_id AND sheets.study_date < s2.study_date").where("s2.id IS NULL")
  end

  def self.first_entry
    self.scoped().joins("LEFT JOIN sheets s2 ON sheets.subject_id = s2.subject_id AND sheets.study_date > s2.study_date").where("s2.id IS NULL")
  end

  def destroy
    update_column :deleted, true
  end

  def name
    self.design.name
  end

  def description
    self.design.description
  end

  def email_subject_template(current_user)
    return "#{self.project.name} #{self.name} Receipt: #{self.subject.subject_code}" if self.design.email_subject_template.to_s.strip.blank?
    result = ''
    result = self.design.email_subject_template.to_s.gsub(/\$\((.*?)\)(\.name|\.label|\.value)?/){|m| variable_replacement($1,$2)}
    result = result.gsub(/\#\(subject\)(\.acrostic)?/){|m| subject_replacement($1)}
    result = result.gsub(/\#\(site\)/){|m| site_replacement($1)}
    result = result.gsub(/\#\(date\)/){|m| date_replacement($1)}
    result = result.gsub(/\#\(project\)/){|m| project_replacement($1)}
    result = result.gsub(/\#\(design\)/){|m| design_replacement($1)}
    result
  end

  def email_body_template(current_user)
    result = ''
    result = self.design.email_template.to_s.gsub(/\$\((.*?)\)(\.name|\.label|\.value)?/){|m| variable_replacement($1,$2)}
    result = result.gsub(/\#\(subject\)(\.acrostic)?/){|m| subject_replacement($1)}
    result = result.gsub(/\#\(site\)/){|m| site_replacement($1)}
    result = result.gsub(/\#\(date\)/){|m| date_replacement($1)}
    result = result.gsub(/\#\(project\)/){|m| project_replacement($1)}
    result = result.gsub(/\#\(design\)/){|m| design_replacement($1)}
    result
  end

  def variable_replacement(variable_name, display_name)
    variable = self.variables.find_by_name(variable_name)
    if variable and display_name.blank?
      variable.response_name(self)
    elsif variable and display_name == '.name'
      variable.display_name
    elsif variable and display_name == '.label'
      variable.response_label(self)
    elsif variable and display_name == '.value'
      variable.response_raw(self)
    else
      ''
    end
  end

  def subject_replacement(property)
    result = ''
    result = if property.blank?
      self.subject.subject_code
    elsif property == '.acrostic'
      self.subject.acrostic.to_s
    end
    result
  end

  def site_replacement(property)
    self.subject.site.name
  end

  def date_replacement(property)
    self.study_date
  end

  def project_replacement(property)
    self.project.name
  end

  def design_replacement(property)
    self.design.name
  end

  # stratum can be nil (grouping on site) or a variable (grouping on the variable responses)
  def self.with_stratum(stratum_id, stratum_value)
    if stratum_id == nil
      self.with_site(stratum_value)
    elsif stratum_id != nil and not stratum_value.blank?
      self.with_variable_response(stratum_id, stratum_value)
    else
      self.without_variable_response(stratum_id)
    end
  end

  def self.sheet_after_variable(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_after(variable, date)
    else
      self.sheet_after(date)
    end
  end

  def self.sheet_before_variable(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_before(variable, date)
    else
      self.sheet_before(date)
    end
  end

  def self.sheet_after_variable_with_blank(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_after_with_blank(variable, date)
    else
      self.sheet_after(date)
    end
  end

  def self.sheet_before_variable_with_blank(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_before_with_blank(variable, date)
    else
      self.sheet_before(date)
    end
  end


  def self.sheet_responses(variable)
    self.scoped().collect{|sheet| sheet.sheet_variables.where(variable_id: variable.id).pluck(:response)}.flatten
  end

end

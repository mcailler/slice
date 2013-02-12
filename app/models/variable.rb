class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :display_name, :variable_type, :project_id, :updater_id, :display_name_visibility, :prepend, :append,
                  # Integer and Numeric
                  :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
                  # Date
                  :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
                  # Date and Time
                  :show_current_button,
                  # Calculated
                  :calculation, :format,
                  # Integer and Numeric and Calculated
                  :units,
                  # Grid
                  :grid_tokens, :grid_variables, :multiple_rows, :default_row_number,
                  # Autocomplete
                  :autocomplete_values,
                  # Radio and Checkbox
                  :alignment,
                  # Scale
                  :scale_type, :domain_id

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'time', 'file', 'calculated', 'grid', 'scale'].sort.collect{|i| [i,i]}
  CONTROL_SIZE = ['mini', 'small', 'medium', 'large', 'xlarge', 'xxlarge'].collect{|i| [i,i]}
  DISPLAY_NAME_VISIBILITY = [['Visible', 'visible'], ['Invisible', 'invisible'], ['Gone', 'gone']]
  ALIGNMENT = [['Horizontal', 'horizontal'], ['Vertical', 'vertical']]
  SCALE_TYPE = ['checkbox', 'radio'].collect{|i| [i,i]}

  serialize :options, Array
  serialize :grid_variables, Array

  before_save :check_for_duplicate_variables

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ? or LOWER(display_name) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ] } }
  scope :with_user, lambda { |*args| { conditions: ['variables.user_id IN (?)', args.first] } }
  scope :with_project, lambda { |*args| { conditions: ['variables.project_id IN (?)', args.first] } }
  scope :with_variable_type, lambda { |*args| { conditions: ['variables.variable_type IN (?)', args.first] } }
  scope :without_variable_type, lambda { |*args| { conditions: ['variables.variable_type NOT IN (?)', args.first] } }

  # Model Validation
  validates_presence_of :name, :display_name, :variable_type, :project_id
  validates_format_of :name, with: /\A[a-z]\w*\Z/i
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :domain
  has_many :sheet_variables
  has_many :grids
  has_many :responses
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'

  # Model Methods

  def header_without_tags
    self.header.to_s.gsub(/<(.*?)>/, '')
  end

  def shared_options
    # if ['scale'].include?(self.variable_type)
      self.domain ? self.domain.options : []
    # else
      # self.options
    # end
  end

  def autocomplete_array
    self.autocomplete_values.to_s.split(/[\n\r]/).collect{|i| i.strip}
  end

  def designs
    @designs ||= begin
      Design.current.select{|d| d.variable_ids.include?(self.id)}.sort_by(&:name)
    end
  end

  def name_with_project
    "#{self.name} - #{self.project.name}"
  end

  def editable_by?(current_user)
    current_user.all_variables.pluck(:id).include?(self.id)
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at', 'options'].include?(key.to_s)}
  end

  def check_for_duplicate_variables
    result = true
    variable_ids = self.grid_variables.collect{|grid_variable| grid_variable[:variable_id]}
    if variable_ids.uniq.size < variable_ids.size
      self.errors.add(:grid, "variables must be unique" )
      result = false
    end
    result
  end

  # For tooltip
  def display_name_range
    [self.display_name, self.range_tooltip].select{|i| not i.blank?}.join(' ')
  end

  def range_tooltip
    result = ""
    minimum = self.hard_minimum || self.soft_minimum
    maximum = self.hard_maximum || self.soft_maximum
    if not minimum.blank? and not maximum.blank?
      result = "[#{minimum}, #{maximum}]" + (self.units.blank? ? "" : " #{self.units}")
    elsif minimum.blank? and not maximum.blank?
      result = "<= #{maximum}" + (self.units.blank? ? "" : " #{self.units}")
    elsif maximum.blank? and not minimum.blank?
      result = ">= #{minimum}" + (self.units.blank? ? "" : " #{self.units}")
    end
    result
  end

  def description_range
    [self.description, self.range_table].select{|i| not i.blank?}.join('<br /><br />')
  end

  def range_table
    result = ""
    if self.hard_minimum or self.hard_maximum or self.soft_minimum or self.soft_maximum
      result += "<table class='table table-bordered table-striped' style='margin-bottom:0px'>"
      result += "<thead><tr><th>Hard Min</th><th>Soft Min</th><th>Soft Max</th><th>Hard Max</th></tr></thead>"
      result += "<tbody><tr><td>#{self.hard_minimum}</td><td>#{self.soft_minimum}</td><td>#{self.soft_maximum}</td><td>#{self.hard_maximum}</td></tr></tbody>"
      result += "</table>"
    end
    result
  end

  def grid_tokens=(tokens)
    self.grid_variables = []
    tokens.each_pair do |key, grid_hash|
      self.grid_variables << { variable_id: grid_hash[:variable_id].strip.to_i,
                               control_size: Variable::CONTROL_SIZE.flatten.uniq.include?(grid_hash[:control_size].to_s.strip) ? grid_hash[:control_size].to_s.strip : 'large'
                             } if grid_hash[:variable_id].strip.to_i > 0
    end
  end

  def missing_codes
    self.shared_options.select{|opt| opt[:missing_code] == '1'}.collect{|opt| opt[:value]}
  end

  def first_scale_variable?(design)
    return true unless design and self.header.blank?

    previous_variable = design.variables[design.variable_ids.index(self.id) - 1] if design.variable_ids.index(self.id) > 0
    # While this could just compare the variable domains, comparing the shared options allows scales with different domains (that have the same options) to still stack nicely on a form
    if previous_variable and previous_variable.variable_type == 'scale' and previous_variable.shared_options == self.shared_options
      return false
    else
      return true
    end
  end

  def options_missing_at_end
    self.shared_options.sort{|a, b| a[:missing_code].to_i <=> b[:missing_code].to_i}
  end

  def options_without_missing
    self.shared_options.select{|opt| opt[:missing_code] != '1'}
  end

  def options_only_missing
    self.shared_options.select{|opt| opt[:missing_code] == '1'}
  end

  def grouped_by_missing
    [ ['', self.options_without_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}], ['Missing', self.options_only_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}] ]
  end

  def response_file(sheet)
    result = ''
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    result = sheet_variable.response_file if sheet_variable
    result
  end

  def response_file_url(sheet)
    result = ''
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    result = sheet_variable.response_file_url if sheet_variable
    result
  end

  def response_name(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    responses = (sheet_variable ? sheet_variable.responses.pluck(:value) : []) # For checkboxes

    if ['dropdown', 'radio'].include?(self.variable_type) or (self.variable_type == 'scale' and self.scale_type == 'radio')
      hash = (self.shared_options.select{|option| option[:value] == response}.first || {})
      [hash[:value], hash[:name]].compact.join(': ')
    elsif ['checkbox'].include?(self.variable_type) or (self.variable_type == 'scale' and self.scale_type == 'checkbox')
      self.shared_options.select{|option| responses.include?(option[:value])}.collect{|option| option[:value] + ": " + option[:name]}
    elsif ['grid'].include?(self.variable_type) and sheet_variable
      grid_labeled = []
      (0..sheet_variable.grids.pluck(:position).max.to_i).each do |position|
        self.grid_variables.each do |grid_variable|
          grid = sheet_variable.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
          grid_labeled[position] ||= {}
          grid_labeled[position][grid.variable.name] = grid.response_label if grid
        end
      end
      grid_labeled.to_json
    elsif ['integer', 'numeric'].include?(self.variable_type)
      hash = self.options_only_missing.select{|option| option[:value] == response}.first
      hash.blank? ? response : [hash[:value], hash[:name]].compact.join(': ')
    elsif ['file'].include?(self.variable_type)
      self.response_file(sheet).size > 0 ? self.response_file(sheet).to_s.split('/').last : ''
    else
      response
    end
  end

  def response_label(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    responses = (sheet_variable ? sheet_variable.responses.pluck(:value) : []) # For checkboxes

    if ['dropdown', 'radio'].include?(self.variable_type) or (self.variable_type == 'scale' and self.scale_type == 'radio')
      hash = (self.shared_options.select{|option| option[:value] == response}.first || {})
      hash[:name]
    elsif ['checkbox'].include?(self.variable_type) or (self.variable_type == 'scale' and self.scale_type == 'checkbox')
      self.shared_options.select{|option| responses.include?(option[:value])}.collect{|option| option[:name]}.join(',')
    elsif ['grid'].include?(self.variable_type) and sheet_variable
      grid_labeled = []
      (0..sheet_variable.grids.pluck(:position).max.to_i).each do |position|
        self.grid_variables.each do |grid_variable|
          grid = sheet_variable.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
          grid_labeled[position] ||= {}
          grid_labeled[position][grid.variable.name] = grid.response_label if grid
        end
      end
      grid_labeled.to_json
    elsif ['integer', 'numeric'].include?(self.variable_type)
      hash = self.options_only_missing.select{|option| option[:value] == response}.first
      hash.blank? ? response : hash[:name]
    elsif ['file'].include?(self.variable_type)
      self.response_file(sheet).to_s.split('/').last
    else
      response
    end
  end

  def response_raw(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    responses = (sheet_variable ? sheet_variable.responses.pluck(:value) : []) # For checkboxes

    if ['dropdown', 'radio'].include?(self.variable_type) or (self.variable_type == 'scale' and self.scale_type == 'radio')
      begin Integer(response) end rescue response
    elsif ['checkbox'].include?(self.variable_type) or (self.variable_type == 'scale' and self.scale_type == 'checkbox')
      self.shared_options.select{|option| responses.include?(option[:value])}.collect{|option| option[:value]}.join(',')
    elsif ['file'].include?(self.variable_type)
      self.response_file(sheet).to_s.split('/').last
    elsif ['grid'].include?(self.variable_type) and sheet_variable
      grid_raw = []
      (0..sheet_variable.grids.pluck(:position).max.to_i).each do |position|
        self.grid_variables.each do |grid_variable|
          grid = sheet_variable.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
          grid_raw[position] ||= {}
          grid_raw[position][grid.variable.name] = grid.response_raw if grid
        end
      end
      grid_raw.to_json
    elsif self.variable_type == 'numeric' or self.variable_type == 'calculated'
      begin Float(response) end rescue response
    elsif self.variable_type == 'integer'
      begin Integer(response) end rescue response
    else
      response
    end
  end

  def response_color(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    color = self.shared_options.select{|option| response == option[:value]}.collect{|option| option[:color]}.first
    color.blank? ? '#ffffff' : color
  end

  def options_or_autocomplete(include_missing)
    if self.variable_type == 'string'
      NaturalSort::naturalsort(self.autocomplete_array.select{|val| not val.blank?}.collect{|val| { name: val, value: val }}) +
      NaturalSort::naturalsort(self.user_submitted_sheet_variables.collect{|sv| { name: sv.response, value: sv.response, info: 'User Submitted' }}.uniq{|a| a[:value].downcase })
    else
      (include_missing ? self.shared_options : self.options_without_missing)
    end
  end

  # Responses that are user submitted and not on autocomplete list
  def user_submitted_sheet_variables
    self.sheet_variables.select{|sv| not self.autocomplete_array.include?(sv.response.to_s.strip) and not sv.response.to_s.strip.blank?}
  end

  def formatted_calculation
    self.calculation.to_s.gsub(/\?|\:/, '<br/>&nbsp;\0<br/>').html_safe
  end

  def has_statistics?
    ['integer', 'numeric', 'calculated'].include?(self.variable_type)
  end

  def report_strata(include_missing, max_strata = 0)
    @report_strata = if self.has_statistics?
      [ { filters: [], name: 'N',      calculation: 'array_count'                            },
        { filters: [], name: 'Mean',   calculation: 'array_mean'                             },
        { filters: [], name: 'StdDev', calculation: 'array_standard_deviation', symbol: 'pm' },
        { filters: [], name: 'Median', calculation: 'array_median'                           },
        { filters: [], name: 'Min',    calculation: 'array_min'                              },
        { filters: [], name: 'Max',    calculation: 'array_max'                              }]
    elsif ['dropdown', 'radio', 'string'].include?(self.variable_type)
      options_or_autocomplete(include_missing).collect{ |h| h.merge({ filters: [{ variable_id: self.id, value: h[:value] }]}) }
    elsif self.variable_type == 'site' and self.project
      self.project.sites.collect{|site| { filters: [{ variable_id: 'site', value: site.id.to_s }], name: site.name, value: site.id.to_s, calculation: 'array_count' } }
    else
      []
    end
    @report_strata << { filters: [{ variable_id: self.id, value: nil }], name: '', value: nil } if include_missing and not ['site'].include?(self.variable_type)
    @report_strata.collect!{|s| s.merge({ calculator: self, variable_id: self.id })}
    @report_strata[0..(max_strata - 1)]
  end

  def self.site(project_id)
    self.new( project_id: project_id, name: 'site', display_name: 'Site', variable_type: 'site' )
  end

end

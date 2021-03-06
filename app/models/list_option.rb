class ListOption < ActiveRecord::Base

  # Model Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :list
  belongs_to :option, class_name: 'StratificationFactorOption', foreign_key: 'option_id'

  # Model Methods
  def name
    self.option.label
  end

end

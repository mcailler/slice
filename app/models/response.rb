class Response < ActiveRecord::Base
  # attr_accessible :sheet_id, :grid_id, :sheet_variable_id, :user_id, :value, :variable_id

  # Model Validation
  validates_presence_of :variable_id, :value

  # Model Relationships
  belongs_to :variable
  belongs_to :sheet
  belongs_to :sheet_variable
  belongs_to :grid
  belongs_to :user

end

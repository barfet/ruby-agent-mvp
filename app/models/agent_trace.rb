class AgentTrace < ApplicationRecord
  belongs_to :message

  validates :agent_type, presence: true
  validates :operation_type, presence: true

  # Scopes for filtering traces by agent type
  scope :by_agent_type, ->(agent_type) { where(agent_type: agent_type) }
  scope :by_operation_type, ->(operation_type) { where(operation_type: operation_type) }

  # Get input data with symbolized keys
  def input_data_symbolized
    input_data.deep_symbolize_keys
  rescue
    input_data
  end

  # Get output data with symbolized keys
  def output_data_symbolized
    output_data.deep_symbolize_keys
  rescue
    output_data
  end
end 
class Message < ApplicationRecord
  belongs_to :support_session
  has_many :agent_traces, dependent: :destroy

  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant system] }

  # Scopes
  scope :user_messages, -> { where(role: 'user') }
  scope :assistant_messages, -> { where(role: 'assistant') }
  scope :system_messages, -> { where(role: 'system') }

  # Format message as Hash for LLM API
  def as_llm_message
    {
      role: role,
      content: content
    }
  end

  # Create a new message with associated agent traces
  def self.create_with_traces(attributes = {}, traces = [])
    message = nil
    
    transaction do
      message = create!(attributes)
      
      traces.each do |trace_attributes|
        message.agent_traces.create!(trace_attributes)
      end
    end
    
    message
  end
end 
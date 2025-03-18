class SupportSession < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :support_tickets, dependent: :destroy

  validates :user_id, presence: true
  validates :status, presence: true, inclusion: { in: %w[active archived closed] }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :archived, -> { where(status: 'archived') }
  scope :closed, -> { where(status: 'closed') }

  # Return conversation history as an array of message hashes
  def conversation_history
    messages.order(:created_at).map do |message|
      {
        role: message.role,
        content: message.content,
        created_at: message.created_at
      }
    end
  end
end 
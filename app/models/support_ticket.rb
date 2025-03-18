class SupportTicket < ApplicationRecord
  belongs_to :support_session

  validates :external_ticket_id, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[open in_progress resolved closed] }

  # Scopes
  scope :open, -> { where(status: 'open') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :resolved, -> { where(status: 'resolved') }
  scope :closed, -> { where(status: 'closed') }

  # Get metadata with symbolized keys
  def metadata_symbolized
    metadata.deep_symbolize_keys
  rescue
    metadata
  end

  # Update ticket status
  def update_status(new_status)
    update(status: new_status)
  end

  # Create a support ticket from a session
  def self.create_from_session(support_session, attributes = {})
    create!(
      support_session: support_session,
      external_ticket_id: attributes[:external_ticket_id],
      status: attributes[:status] || 'open',
      priority: attributes[:priority],
      description: attributes[:description],
      metadata: attributes[:metadata] || {}
    )
  end
end 
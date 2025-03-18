class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :support_session, null: false, foreign_key: true
      t.string :external_ticket_id, null: false
      t.string :status, null: false, default: 'open'
      t.string :priority
      t.text :description
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :support_tickets, :external_ticket_id, unique: true
    add_index :support_tickets, :status
  end
end

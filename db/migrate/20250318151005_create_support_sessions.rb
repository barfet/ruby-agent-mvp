class CreateSupportSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :support_sessions do |t|
      t.integer :user_id, null: false
      t.string :status, default: 'active'
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :support_sessions, :user_id
    add_index :support_sessions, :status
  end
end

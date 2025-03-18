class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :support_session, null: false, foreign_key: true
      t.text :content, null: false
      t.string :role, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :messages, :role
  end
end

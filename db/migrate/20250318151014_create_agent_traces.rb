class CreateAgentTraces < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_traces do |t|
      t.references :message, null: false, foreign_key: true
      t.string :agent_type, null: false
      t.string :operation_type, null: false
      t.jsonb :input_data, default: {}
      t.jsonb :output_data, default: {}

      t.timestamps
    end

    add_index :agent_traces, :agent_type
    add_index :agent_traces, :operation_type
  end
end

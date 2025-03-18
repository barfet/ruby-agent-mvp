class CreateKnowledgeDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :knowledge_documents do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.jsonb :metadata, default: {}
      t.string :vector_store_id
      t.string :source_url
      t.string :document_type

      t.timestamps
    end

    add_index :knowledge_documents, :title
    add_index :knowledge_documents, :vector_store_id
    add_index :knowledge_documents, :document_type
  end
end

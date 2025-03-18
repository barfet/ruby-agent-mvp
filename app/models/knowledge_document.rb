class KnowledgeDocument < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true

  # Scopes
  scope :by_document_type, ->(document_type) { where(document_type: document_type) }
  
  # Search for documents by title or content
  scope :search, ->(query) do
    where("title ILIKE ? OR content ILIKE ?", "%#{query}%", "%#{query}%")
  end

  # Get metadata with symbolized keys
  def metadata_symbolized
    metadata.deep_symbolize_keys
  rescue
    metadata
  end

  # Update vector store id (hook for integration with vector database)
  def update_vector_store_id(id)
    update(vector_store_id: id)
  end
end 
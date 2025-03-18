# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_18_151023) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agent_traces", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.string "agent_type", null: false
    t.string "operation_type", null: false
    t.jsonb "input_data", default: {}
    t.jsonb "output_data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_type"], name: "index_agent_traces_on_agent_type"
    t.index ["message_id"], name: "index_agent_traces_on_message_id"
    t.index ["operation_type"], name: "index_agent_traces_on_operation_type"
  end

  create_table "knowledge_documents", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.jsonb "metadata", default: {}
    t.string "vector_store_id"
    t.string "source_url"
    t.string "document_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_type"], name: "index_knowledge_documents_on_document_type"
    t.index ["title"], name: "index_knowledge_documents_on_title"
    t.index ["vector_store_id"], name: "index_knowledge_documents_on_vector_store_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "support_session_id", null: false
    t.text "content", null: false
    t.string "role", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_messages_on_role"
    t.index ["support_session_id"], name: "index_messages_on_support_session_id"
  end

  create_table "support_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "status", default: "active"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_support_sessions_on_status"
    t.index ["user_id"], name: "index_support_sessions_on_user_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "support_session_id", null: false
    t.string "external_ticket_id", null: false
    t.string "status", default: "open", null: false
    t.string "priority"
    t.text "description"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_ticket_id"], name: "index_support_tickets_on_external_ticket_id", unique: true
    t.index ["status"], name: "index_support_tickets_on_status"
    t.index ["support_session_id"], name: "index_support_tickets_on_support_session_id"
  end

  add_foreign_key "agent_traces", "messages"
  add_foreign_key "messages", "support_sessions"
  add_foreign_key "support_tickets", "support_sessions"
end

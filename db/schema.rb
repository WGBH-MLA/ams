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

ActiveRecord::Schema.define(version: 2023_08_30_155065) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "admin_data", force: :cascade do |t|
    t.text "sonyci_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "hyrax_batch_ingest_batch_id"
    t.bigint "last_pushed"
    t.bigint "last_updated"
    t.boolean "needs_update"
    t.bigint "bulkrax_importer_id"
    t.index ["bulkrax_importer_id"], name: "idx_16387_index_admin_data_on_bulkrax_importer_id"
    t.index ["hyrax_batch_ingest_batch_id"], name: "idx_16387_index_admin_data_on_hyrax_batch_ingest_batch_id"
  end

  create_table "annotations", force: :cascade do |t|
    t.string "annotation_type", limit: 255
    t.string "ref", limit: 255
    t.string "source", limit: 255
    t.string "annotation", limit: 255
    t.string "version", limit: 255
    t.string "value", limit: 255
    t.bigint "admin_data_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_data_id"], name: "idx_16394_index_annotations_on_admin_data_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_type", limit: 255
    t.string "document_id", limit: 255
    t.string "document_type", limit: 255
    t.binary "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "idx_16413_index_bookmarks_on_document_id"
    t.index ["user_id"], name: "idx_16413_index_bookmarks_on_user_id"
  end

  create_table "bulkrax_entries", force: :cascade do |t|
    t.string "importerexporter_type", limit: 255, default: "Bulkrax::Importer"
    t.string "identifier", limit: 255
    t.string "collection_ids", limit: 255
    t.string "type", limit: 255
    t.bigint "importerexporter_id"
    t.text "raw_metadata"
    t.text "parsed_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_error_at"
    t.datetime "last_succeeded_at"
    t.bigint "import_attempts", default: 0
    t.index ["identifier"], name: "idx_16423_index_bulkrax_entries_on_identifier"
    t.index ["importerexporter_id", "importerexporter_type"], name: "idx_16423_bulkrax_entries_importerexporter_idx"
    t.index ["importerexporter_id"], name: "idx_16423_index_bulkrax_entries_on_importerexporter_id"
    t.index ["type"], name: "idx_16423_index_bulkrax_entries_on_type"
  end

  create_table "bulkrax_exporter_runs", force: :cascade do |t|
    t.bigint "exporter_id"
    t.bigint "total_work_entries", default: 0
    t.bigint "enqueued_records", default: 0
    t.bigint "processed_records", default: 0
    t.bigint "deleted_records", default: 0
    t.bigint "failed_records", default: 0
    t.index ["exporter_id"], name: "idx_16451_index_bulkrax_exporter_runs_on_exporter_id"
  end

  create_table "bulkrax_exporters", force: :cascade do |t|
    t.string "name", limit: 255
    t.bigint "user_id"
    t.string "parser_klass", limit: 255
    t.bigint "limit"
    t.text "parser_fields"
    t.text "field_mapping"
    t.string "export_source", limit: 255
    t.string "export_from", limit: 255
    t.string "export_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_error_at"
    t.datetime "last_succeeded_at"
    t.date "start_date"
    t.date "finish_date"
    t.string "work_visibility", limit: 255
    t.string "workflow_status", limit: 255
    t.boolean "include_thumbnails", default: false
    t.boolean "generated_metadata", default: false
    t.index ["user_id"], name: "idx_16435_index_bulkrax_exporters_on_user_id"
  end

  create_table "bulkrax_importer_runs", force: :cascade do |t|
    t.bigint "importer_id"
    t.bigint "total_work_entries", default: 0
    t.bigint "enqueued_records", default: 0
    t.bigint "processed_records", default: 0
    t.bigint "deleted_records", default: 0
    t.bigint "failed_records", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "processed_collections", default: 0
    t.bigint "failed_collections", default: 0
    t.bigint "total_collection_entries", default: 0
    t.bigint "processed_relationships", default: 0
    t.bigint "failed_relationships", default: 0
    t.text "invalid_records"
    t.bigint "processed_file_sets", default: 0
    t.bigint "failed_file_sets", default: 0
    t.bigint "total_file_set_entries", default: 0
    t.bigint "processed_works", default: 0
    t.bigint "failed_works", default: 0
    t.index ["importer_id"], name: "idx_16472_index_bulkrax_importer_runs_on_importer_id"
  end

  create_table "bulkrax_importers", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "admin_set_id", limit: 255
    t.bigint "user_id"
    t.string "frequency", limit: 255
    t.string "parser_klass", limit: 255
    t.bigint "limit"
    t.text "parser_fields"
    t.text "field_mapping"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "validate_only"
    t.datetime "last_error_at"
    t.datetime "last_succeeded_at"
    t.index ["user_id"], name: "idx_16461_index_bulkrax_importers_on_user_id"
  end

  create_table "bulkrax_pending_relationships", force: :cascade do |t|
    t.bigint "importer_run_id", null: false
    t.string "parent_id", limit: 255, null: false
    t.string "child_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order", default: 0
    t.index ["child_id"], name: "idx_16494_index_bulkrax_pending_relationships_on_child_id"
    t.index ["importer_run_id"], name: "idx_16494_index_bulkrax_pending_relationships_on_importer_run_i"
    t.index ["parent_id"], name: "idx_16494_index_bulkrax_pending_relationships_on_parent_id"
  end

  create_table "bulkrax_statuses", force: :cascade do |t|
    t.string "status_message", limit: 255
    t.string "error_class", limit: 255
    t.text "error_message"
    t.text "error_backtrace"
    t.bigint "statusable_id"
    t.string "statusable_type", limit: 255
    t.bigint "runnable_id"
    t.string "runnable_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["error_class"], name: "idx_16502_index_bulkrax_statuses_on_error_class"
    t.index ["runnable_id", "runnable_type"], name: "idx_16502_bulkrax_statuses_runnable_idx"
    t.index ["statusable_id", "statusable_type"], name: "idx_16502_bulkrax_statuses_statusable_idx"
  end

  create_table "checksum_audit_logs", force: :cascade do |t|
    t.string "file_set_id", limit: 255
    t.string "file_id", limit: 255
    t.string "checked_uri", limit: 255
    t.string "expected_result", limit: 255
    t.string "actual_result", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "passed"
    t.index ["checked_uri"], name: "idx_16513_index_checksum_audit_logs_on_checked_uri"
    t.index ["file_set_id", "file_id"], name: "idx_16513_by_file_set_id_and_file_id"
  end

  create_table "collection_branding_infos", force: :cascade do |t|
    t.string "collection_id", limit: 255
    t.string "role", limit: 255
    t.string "local_path", limit: 255
    t.string "alt_text", limit: 255
    t.string "target_url", limit: 255
    t.bigint "height"
    t.bigint "width"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collection_type_participants", force: :cascade do |t|
    t.bigint "hyrax_collection_type_id"
    t.string "agent_type", limit: 255
    t.string "agent_id", limit: 255
    t.string "access", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hyrax_collection_type_id"], name: "idx_16537_hyrax_collection_type_id"
  end

  create_table "content_blocks", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_key", limit: 255
  end

  create_table "curation_concerns_operations", force: :cascade do |t|
    t.string "status", limit: 255
    t.string "operation_type", limit: 255
    t.string "job_class", limit: 255
    t.string "job_id", limit: 255
    t.string "type", limit: 255
    t.text "message"
    t.bigint "user_id"
    t.bigint "parent_id"
    t.bigint "lft", null: false
    t.bigint "rgt", null: false
    t.bigint "depth", default: 0, null: false
    t.bigint "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lft"], name: "idx_16556_index_curation_concerns_operations_on_lft"
    t.index ["parent_id"], name: "idx_16556_index_curation_concerns_operations_on_parent_id"
    t.index ["rgt"], name: "idx_16556_index_curation_concerns_operations_on_rgt"
    t.index ["user_id"], name: "idx_16556_index_curation_concerns_operations_on_user_id"
  end

  create_table "featured_works", force: :cascade do |t|
    t.bigint "order", default: 5
    t.string "work_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order"], name: "idx_16570_index_featured_works_on_order"
    t.index ["work_id"], name: "idx_16570_index_featured_works_on_work_id"
  end

  create_table "file_download_stats", force: :cascade do |t|
    t.datetime "date"
    t.bigint "downloads"
    t.string "file_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["file_id"], name: "idx_16577_index_file_download_stats_on_file_id"
    t.index ["user_id"], name: "idx_16577_index_file_download_stats_on_user_id"
  end

  create_table "file_view_stats", force: :cascade do |t|
    t.datetime "date"
    t.bigint "views"
    t.string "file_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["file_id"], name: "idx_16583_index_file_view_stats_on_file_id"
    t.index ["user_id"], name: "idx_16583_index_file_view_stats_on_user_id"
  end

  create_table "hyrax_batch_ingest_batch_items", force: :cascade do |t|
    t.bigint "batch_id"
    t.string "id_within_batch", limit: 255
    t.text "source_data"
    t.string "source_location", limit: 255
    t.string "status", limit: 255
    t.text "error"
    t.string "repo_object_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repo_object_class_name", limit: 255
    t.index ["batch_id"], name: "idx_16602_index_hyrax_batch_ingest_batch_items_on_batch_id"
  end

  create_table "hyrax_batch_ingest_batches", force: :cascade do |t|
    t.string "status", limit: 255
    t.string "submitter_email", limit: 255
    t.string "source_location", limit: 255
    t.text "error"
    t.string "admin_set_id", limit: 255
    t.string "ingest_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uploaded_filename", limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
  end

  create_table "hyrax_collection_types", force: :cascade do |t|
    t.string "title", limit: 255
    t.text "description"
    t.string "machine_id", limit: 255
    t.boolean "nestable", default: true, null: false
    t.boolean "discoverable", default: true, null: false
    t.boolean "sharable", default: true, null: false
    t.boolean "allow_multiple_membership", default: true, null: false
    t.boolean "require_membership", default: false, null: false
    t.boolean "assigns_workflow", default: false, null: false
    t.boolean "assigns_visibility", default: false, null: false
    t.boolean "share_applies_to_new_works", default: true, null: false
    t.boolean "brandable", default: true, null: false
    t.string "badge_color", limit: 255, default: "#663333"
    t.index ["machine_id"], name: "idx_16614_index_hyrax_collection_types_on_machine_id", unique: true
  end

  create_table "hyrax_features", force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instantiation_admin_data", force: :cascade do |t|
    t.string "aapb_preservation_lto", limit: 255
    t.string "aapb_preservation_disk", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "md5", limit: 255
  end

  create_table "job_io_wrappers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "uploaded_file_id"
    t.string "file_set_id", limit: 255
    t.string "mime_type", limit: 255
    t.string "original_name", limit: 255
    t.string "path", limit: 255
    t.string "relation", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uploaded_file_id"], name: "idx_16649_index_job_io_wrappers_on_uploaded_file_id"
    t.index ["user_id"], name: "idx_16649_index_job_io_wrappers_on_user_id"
  end

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.string "unsubscriber_type", limit: 255
    t.bigint "unsubscriber_id"
    t.bigint "conversation_id"
    t.index ["conversation_id"], name: "idx_16667_index_mailboxer_conversation_opt_outs_on_conversation"
    t.index ["unsubscriber_id", "unsubscriber_type"], name: "idx_16667_index_mailboxer_conversation_opt_outs_on_unsubscriber"
  end

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string "subject", limit: 255, default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string "type", limit: 255
    t.text "body"
    t.string "subject", limit: 255, default: ""
    t.string "sender_type", limit: 255
    t.bigint "sender_id"
    t.bigint "conversation_id"
    t.boolean "draft", default: false
    t.string "notification_code", limit: 255
    t.string "notified_object_type", limit: 255
    t.bigint "notified_object_id"
    t.string "attachment", limit: 255
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.boolean "global", default: false
    t.datetime "expires"
    t.index ["conversation_id"], name: "idx_16673_index_mailboxer_notifications_on_conversation_id"
    t.index ["notified_object_id", "notified_object_type"], name: "idx_16673_index_mailboxer_notifications_on_notified_object_id_a"
    t.index ["notified_object_type", "notified_object_id"], name: "idx_16673_mailboxer_notifications_notified_object"
    t.index ["sender_id", "sender_type"], name: "idx_16673_index_mailboxer_notifications_on_sender_id_and_sender"
    t.index ["type"], name: "idx_16673_index_mailboxer_notifications_on_type"
  end

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.string "receiver_type", limit: 255
    t.bigint "receiver_id"
    t.bigint "notification_id", null: false
    t.boolean "is_read", default: false
    t.boolean "trashed", default: false
    t.boolean "deleted", default: false
    t.string "mailbox_type", limit: 25
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_delivered", default: false
    t.string "delivery_method", limit: 255
    t.string "message_id", limit: 255
    t.index ["notification_id"], name: "idx_16688_index_mailboxer_receipts_on_notification_id"
    t.index ["receiver_id", "receiver_type"], name: "idx_16688_index_mailboxer_receipts_on_receiver_id_and_receiver_"
  end

  create_table "minter_states", force: :cascade do |t|
    t.string "namespace", limit: 255, default: "default", null: false
    t.string "template", limit: 255, null: false
    t.text "counters"
    t.bigint "seq", default: 0
    t.binary "rand"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace"], name: "idx_16703_index_minter_states_on_namespace", unique: true
  end

  create_table "orm_resources", id: :text, default: -> { "(uuid_generate_v4())::text" }, force: :cascade do |t|
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "internal_resource"
    t.integer "lock_version"
    t.index ["internal_resource"], name: "index_orm_resources_on_internal_resource"
    t.index ["metadata"], name: "index_orm_resources_on_metadata", using: :gin
    t.index ["metadata"], name: "index_orm_resources_on_metadata_jsonb_path_ops", opclass: :jsonb_path_ops, using: :gin
    t.index ["updated_at"], name: "index_orm_resources_on_updated_at"
  end

  create_table "permission_template_accesses", force: :cascade do |t|
    t.bigint "permission_template_id"
    t.string "agent_type", limit: 255
    t.string "agent_id", limit: 255
    t.string "access", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_template_id", "agent_id", "agent_type", "access"], name: "idx_16722_uk_permission_template_accesses", unique: true
    t.index ["permission_template_id"], name: "idx_16722_index_permission_template_accesses_on_permission_temp"
  end

  create_table "permission_templates", force: :cascade do |t|
    t.string "source_id", limit: 255
    t.string "visibility", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "release_date"
    t.string "release_period", limit: 255
    t.index ["source_id"], name: "idx_16712_index_permission_templates_on_source_id", unique: true
  end

  create_table "proxy_deposit_requests", force: :cascade do |t|
    t.string "work_id", limit: 255, null: false
    t.bigint "sending_user_id", null: false
    t.bigint "receiving_user_id", null: false
    t.datetime "fulfillment_date"
    t.string "status", limit: 255, default: "pending", null: false
    t.text "sender_comment"
    t.text "receiver_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiving_user_id"], name: "idx_16732_index_proxy_deposit_requests_on_receiving_user_id"
    t.index ["sending_user_id"], name: "idx_16732_index_proxy_deposit_requests_on_sending_user_id"
  end

  create_table "proxy_deposit_rights", force: :cascade do |t|
    t.bigint "grantor_id"
    t.bigint "grantee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grantee_id"], name: "idx_16740_index_proxy_deposit_rights_on_grantee_id"
    t.index ["grantor_id"], name: "idx_16740_index_proxy_deposit_rights_on_grantor_id"
  end

  create_table "pushes", force: :cascade do |t|
    t.text "pushed_id_csv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
  end

  create_table "qa_local_authorities", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_16752_index_qa_local_authorities_on_name", unique: true
  end

  create_table "qa_local_authority_entries", force: :cascade do |t|
    t.bigint "local_authority_id"
    t.string "label", limit: 255
    t.string "uri", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_authority_id"], name: "idx_16758_index_qa_local_authority_entries_on_local_authority_i"
    t.index ["uri"], name: "idx_16758_index_qa_local_authority_entries_on_uri", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id", "user_id"], name: "idx_16772_index_roles_users_on_role_id_and_user_id"
    t.index ["role_id"], name: "idx_16772_index_roles_users_on_role_id"
    t.index ["user_id", "role_id"], name: "idx_16772_index_roles_users_on_user_id_and_role_id"
    t.index ["user_id"], name: "idx_16772_index_roles_users_on_user_id"
  end

  create_table "searches", force: :cascade do |t|
    t.binary "query_params"
    t.bigint "user_id"
    t.string "user_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "idx_16779_index_searches_on_user_id"
  end

  create_table "single_use_links", force: :cascade do |t|
    t.string "downloadkey", limit: 255
    t.string "path", limit: 255
    t.string "itemid", limit: 255
    t.datetime "expires"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sipity_agents", force: :cascade do |t|
    t.string "proxy_for_id", limit: 255, null: false
    t.string "proxy_for_type", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_for_id", "proxy_for_type"], name: "idx_16797_sipity_agents_proxy_for", unique: true
  end

  create_table "sipity_comments", force: :cascade do |t|
    t.bigint "entity_id", null: false
    t.bigint "agent_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "idx_16804_index_sipity_comments_on_agent_id"
    t.index ["created_at"], name: "idx_16804_index_sipity_comments_on_created_at"
    t.index ["entity_id"], name: "idx_16804_index_sipity_comments_on_entity_id"
  end

  create_table "sipity_entities", force: :cascade do |t|
    t.string "proxy_for_global_id", limit: 255, null: false
    t.bigint "workflow_id", null: false
    t.bigint "workflow_state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_for_global_id"], name: "idx_16811_sipity_entities_proxy_for_global_id", unique: true
    t.index ["workflow_id"], name: "idx_16811_index_sipity_entities_on_workflow_id"
    t.index ["workflow_state_id"], name: "idx_16811_index_sipity_entities_on_workflow_state_id"
  end

  create_table "sipity_entity_specific_responsibilities", force: :cascade do |t|
    t.bigint "workflow_role_id", null: false
    t.string "entity_id", limit: 255, null: false
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "idx_16816_sipity_entity_specific_responsibilities_agent"
    t.index ["entity_id"], name: "idx_16816_sipity_entity_specific_responsibilities_entity"
    t.index ["workflow_role_id", "entity_id", "agent_id"], name: "idx_16816_sipity_entity_specific_responsibilities_aggregate", unique: true
    t.index ["workflow_role_id"], name: "idx_16816_sipity_entity_specific_responsibilities_role"
  end

  create_table "sipity_notifiable_contexts", force: :cascade do |t|
    t.bigint "scope_for_notification_id", null: false
    t.string "scope_for_notification_type", limit: 255, null: false
    t.string "reason_for_notification", limit: 255, null: false
    t.bigint "notification_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "idx_16821_sipity_notifiable_contexts_notification_id"
    t.index ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification", "notification_id"], name: "idx_16821_sipity_notifiable_contexts_concern_surrogate", unique: true
    t.index ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification"], name: "idx_16821_sipity_notifiable_contexts_concern_context"
    t.index ["scope_for_notification_id", "scope_for_notification_type"], name: "idx_16821_sipity_notifiable_contexts_concern"
  end

  create_table "sipity_notification_recipients", force: :cascade do |t|
    t.bigint "notification_id", null: false
    t.bigint "role_id", null: false
    t.string "recipient_strategy", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id", "role_id", "recipient_strategy"], name: "idx_16835_sipity_notifications_recipients_surrogate"
    t.index ["notification_id"], name: "idx_16835_sipity_notification_recipients_notification"
    t.index ["recipient_strategy"], name: "idx_16835_sipity_notification_recipients_recipient_strategy"
    t.index ["role_id"], name: "idx_16835_sipity_notification_recipients_role"
  end

  create_table "sipity_notifications", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "notification_type", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_16828_index_sipity_notifications_on_name", unique: true
    t.index ["notification_type"], name: "idx_16828_index_sipity_notifications_on_notification_type"
  end

  create_table "sipity_roles", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_16840_index_sipity_roles_on_name", unique: true
  end

  create_table "sipity_workflow_actions", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.bigint "resulting_workflow_state_id"
    t.string "name", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resulting_workflow_state_id"], name: "idx_16855_sipity_workflow_actions_resulting_workflow_state"
    t.index ["workflow_id", "name"], name: "idx_16855_sipity_workflow_actions_aggregate", unique: true
    t.index ["workflow_id"], name: "idx_16855_sipity_workflow_actions_workflow"
  end

  create_table "sipity_workflow_methods", force: :cascade do |t|
    t.string "service_name", limit: 255, null: false
    t.bigint "weight", null: false
    t.bigint "workflow_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_action_id"], name: "idx_16860_index_sipity_workflow_methods_on_workflow_action_id"
  end

  create_table "sipity_workflow_responsibilities", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "workflow_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "workflow_role_id"], name: "idx_16865_sipity_workflow_responsibilities_aggregate", unique: true
  end

  create_table "sipity_workflow_roles", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_id", "role_id"], name: "idx_16870_sipity_workflow_roles_aggregate", unique: true
  end

  create_table "sipity_workflow_state_action_permissions", force: :cascade do |t|
    t.bigint "workflow_role_id", null: false
    t.bigint "workflow_state_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_role_id", "workflow_state_action_id"], name: "idx_16885_sipity_workflow_state_action_permissions_aggregate", unique: true
  end

  create_table "sipity_workflow_state_actions", force: :cascade do |t|
    t.bigint "originating_workflow_state_id", null: false
    t.bigint "workflow_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["originating_workflow_state_id", "workflow_action_id"], name: "idx_16880_sipity_workflow_state_actions_aggregate", unique: true
  end

  create_table "sipity_workflow_states", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.string "name", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_16875_index_sipity_workflow_states_on_name"
    t.index ["workflow_id", "name"], name: "idx_16875_sipity_type_state_aggregate", unique: true
  end

  create_table "sipity_workflows", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "label", limit: 255
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "permission_template_id"
    t.boolean "active"
    t.boolean "allows_access_grant"
    t.index ["permission_template_id", "name"], name: "idx_16847_index_sipity_workflows_on_permission_template_and_nam", unique: true
  end

  create_table "sony_ci_webhook_logs", force: :cascade do |t|
    t.string "url", limit: 255
    t.string "action", limit: 255
    t.text "request_headers"
    t.text "request_body"
    t.text "response_headers"
    t.text "response_body"
    t.string "error", limit: 255
    t.string "error_message", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "guids", limit: 255
    t.bigint "response_status"
    t.index ["guids"], name: "idx_16890_index_sony_ci_webhook_logs_on_guids"
  end

  create_table "tinymce_assets", force: :cascade do |t|
    t.string "file", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trophies", force: :cascade do |t|
    t.bigint "user_id"
    t.string "work_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.string "file", limit: 255
    t.bigint "user_id"
    t.string "file_set_uri", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_set_uri"], name: "idx_16914_index_uploaded_files_on_file_set_uri"
    t.index ["user_id"], name: "idx_16914_index_uploaded_files_on_user_id"
  end

  create_table "user_stats", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "date"
    t.bigint "file_views"
    t.bigint "file_downloads"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_views"
    t.index ["user_id"], name: "idx_16959_index_user_stats_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false
    t.string "facebook_handle", limit: 255
    t.string "twitter_handle", limit: 255
    t.string "googleplus_handle", limit: 255
    t.string "display_name", limit: 255
    t.string "address", limit: 255
    t.string "admin_area", limit: 255
    t.string "department", limit: 255
    t.string "title", limit: 255
    t.string "office", limit: 255
    t.string "chat_id", limit: 255
    t.string "website", limit: 255
    t.string "affiliation", limit: 255
    t.string "telephone", limit: 255
    t.string "avatar_file_name", limit: 255
    t.string "avatar_content_type", limit: 255
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "linkedin_handle", limit: 255
    t.string "orcid", limit: 255
    t.string "arkivo_token", limit: 255
    t.string "arkivo_subscription", limit: 255
    t.binary "zotero_token"
    t.string "zotero_userid", limit: 255
    t.string "preferred_locale", limit: 255
    t.datetime "deleted_at"
    t.boolean "deleted", default: false
    t.index ["email"], name: "idx_16923_index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "idx_16923_index_users_on_reset_password_token", unique: true
  end

  create_table "version_committers", force: :cascade do |t|
    t.string "obj_id", limit: 255
    t.string "datastream_id", limit: 255
    t.string "version_id", limit: 255
    t.string "committer_login", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_view_stats", force: :cascade do |t|
    t.datetime "date"
    t.bigint "work_views"
    t.string "work_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "idx_16975_index_work_view_stats_on_user_id"
    t.index ["work_id"], name: "idx_16975_index_work_view_stats_on_work_id"
  end

  add_foreign_key "admin_data", "bulkrax_importers", on_update: :restrict, on_delete: :restrict
  add_foreign_key "admin_data", "hyrax_batch_ingest_batches", on_update: :restrict, on_delete: :restrict
  add_foreign_key "annotations", "admin_data", column: "admin_data_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "bulkrax_exporter_runs", "bulkrax_exporters", column: "exporter_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "bulkrax_importer_runs", "bulkrax_importers", column: "importer_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "bulkrax_pending_relationships", "bulkrax_importer_runs", column: "importer_run_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "collection_type_participants", "hyrax_collection_types", on_update: :restrict, on_delete: :restrict
  add_foreign_key "curation_concerns_operations", "users", on_update: :restrict, on_delete: :restrict
  add_foreign_key "hyrax_batch_ingest_batch_items", "hyrax_batch_ingest_batches", column: "batch_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "permission_template_accesses", "permission_templates", on_update: :restrict, on_delete: :restrict
  add_foreign_key "qa_local_authority_entries", "qa_local_authorities", column: "local_authority_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "uploaded_files", "users", on_update: :restrict, on_delete: :restrict
end

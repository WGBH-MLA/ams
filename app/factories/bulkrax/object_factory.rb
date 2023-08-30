# frozen_string_literal: true

require_dependency Bulkrax::Engine.root.join('app', 'factories', 'bulkrax', 'object_factory')

Bulkrax::ObjectFactory.class_eval do     # rubocop:disable Metrics/ParameterLists
    # rubocop:disable Metrics/ParameterLists
    def initialize(attributes:, source_identifier_value:, work_identifier:, related_parents_parsed_mapping: nil, collection_field_mapping:, replace_files: false, user: nil, klass: nil, importer_run_id: nil, update_files: false, importer: nil)
      @attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)
      @replace_files = replace_files
      @update_files = update_files
      @user = user || User.batch_user
      @work_identifier = work_identifier
      @collection_field_mapping = collection_field_mapping
      @related_parents_parsed_mapping = related_parents_parsed_mapping
      @source_identifier_value = source_identifier_value
      @klass = klass || Bulkrax.default_work_type.constantize
      @importer_run_id = importer_run_id
    end

  # Regardless of what the Parser gives us, these are the properties we are prepared to accept.
  def permitted_attributes
    klass.properties.keys.map(&:to_sym) + %i[id edit_users edit_groups read_groups visibility work_members_attributes admin_set_id member_of_collections_attributes pbcore_xml skip_file_upload_validation bulkrax_importer_id]
  end

end

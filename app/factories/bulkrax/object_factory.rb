# frozen_string_literal: true

require_dependency Bulkrax::Engine.root.join('app', 'factories', 'bulkrax', 'object_factory')

Bulkrax::ObjectFactory.class_eval do     # rubocop:disable Metrics/ParameterLists
    # rubocop:disable Metrics/ParameterLists
    def initialize(attributes:, source_identifier_value:, work_identifier:, collection_field_mapping:, replace_files: false, user: nil, klass: nil, update_files: false)
      @attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes).symbolize_keys
      @replace_files = replace_files
      @update_files = update_files
      @user = user || User.batch_user
      @work_identifier = work_identifier
      @collection_field_mapping = collection_field_mapping
      @source_identifier_value = source_identifier_value
      @klass = klass || Bulkrax.default_work_type.constantize
    end

  def search_by_identifier
    query = { "#{work_identifier}_sim" =>
              source_identifier_value }
    # Query can return partial matches (something6 matches both something6 and something68)
    # so we need to weed out any that are not the correct full match. But other items might be
    # in the multivalued field, so we have to go through them one at a time.
    match = klass.where(query).detect { |m| m.send(work_identifier).include?(source_identifier_value) }
    return match if match
  end

  # Regardless of what the Parser gives us, these are the properties we are prepared to accept.
  def permitted_attributes
    klass.properties.keys.map(&:to_sym) + %i[id edit_users edit_groups read_groups visibility work_members_attributes admin_set_id member_of_collections_attributes pbcore_xml skip_file_upload_validation]
  end
end

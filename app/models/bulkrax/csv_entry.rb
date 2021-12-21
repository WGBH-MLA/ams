# frozen_string_literal: true

require_dependency Bulkrax::Engine.root.join('app', 'models', 'bulkrax', 'csv_entry')

Bulkrax::CsvEntry.class_eval do
  def self.read_data(path)
    raise StandardError, 'CSV path empty' if path.blank?

    CSV.read(path,
      headers: true,
      encoding: 'utf-8')
  end

  def self.data_for_entry(data, _source_id = nil)
    # If a multi-line CSV data is passed, grab the first row
    data = data.first if data.is_a?(CSV::Table)
    # model has to be separated so that it doesn't get mistranslated by to_h
    raw_data = data.to_h
    raw_data[:model] = data[:model] if data[:model].present?
    # If the collection field mapping is not 'collection', add 'collection' - the parser needs it
    raw_data[:collection] = raw_data[collection_field.to_sym] if raw_data.keys.include?(collection_field.to_sym) && collection_field != 'collection'
    # If the children field mapping is not 'children', add 'children' - the parser needs itexi
    raw_data[:children] = raw_data[collection_field.to_sym] if raw_data.keys.include?(children_field.to_sym) && children_field != 'children'
    return raw_data
  end

  def build_metadata
    raise StandardError, 'Record not found' if record.nil?
    raise StandardError, "Missing required elements, missing element(s) are: #{importerexporter.parser.missing_elements(keys_without_numbers(record.keys)).join(', ')}" unless importerexporter.parser.required_elements?(keys_without_numbers(record.keys))

    self.parsed_metadata = {}
    add_identifier
    add_metadata_for_model
    self.parsed_metadata['bulkrax_importer_id'] = importer.id if self.raw_metadata['model'] == 'Asset'
    add_visibility
    validate_csv_headers
    add_ingested_metadata
    add_rights_statement
    add_collections
    add_local

    self.parsed_metadata
  end

  def validate_csv_headers
    csv_headers = raw_metadata.keys - ['annotation', 'children', 'id', 'model', 'ref', 'source', 'version']
    object_class = raw_metadata['model']
    unknown_headers = []

    csv_headers.sort.each do |key|
      unknown_headers << key.dup.prepend(object_class + '.') if valid_header_keys.exclude?(key)
    end

    raise("Unknown column(s) `#{unknown_headers.join(', ')}`. Unable to parse CSV.") if unknown_headers.present?
  end

  def valid_header_keys
    object_class = raw_metadata['model']
    extra_attr = if object_class == "Asset"
                   (AdminData.attribute_names.dup - ['id', 'created_at', 'updated_at'] +
                    Annotation.ingestable_attributes).uniq
                 elsif object_class.include?("Instantiation")
                   (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at'])
                 end
    fedora_attr = object_class.constantize.properties.collect { |p| p.first.dup }
    attr = extra_attr.nil? ? fedora_attr : fedora_attr.concat(extra_attr.deep_dup)

    [[object_class] + attr].flatten
  end
end

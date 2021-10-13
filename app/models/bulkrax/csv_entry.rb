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
end

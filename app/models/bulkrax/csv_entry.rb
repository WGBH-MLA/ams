# frozen_string_literal: true
# OVERRIDE Bulkrax 1.0.2

require_dependency Bulkrax::Engine.root.join('app', 'models', 'bulkrax', 'csv_entry')

Bulkrax::CsvEntry.class_eval do
  include HasAmsMatchers

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
    raw_data[:collection] = raw_data[:collection] if raw_data.keys.include?(:collection)
    # If the children field mapping is not 'children', add 'children' - the parser needs it
    raw_data[:children] = raw_data[:collection] if raw_data.keys.include?(:children)
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
    add_ingested_metadata
    add_rights_statement
    add_collections
    add_local

    self.parsed_metadata
  end

  def build_export_metadata
    # make_round_trippable
    self.parsed_metadata = {}
    build_mapping_metadata

    self.parsed_metadata = flatten_hash(self.parsed_metadata)

    # TODO: fix the "send" parameter in the conditional below
    # currently it returns: "NoMethodError - undefined method 'bulkrax_identifier' for #<Collection:0x00007fbe6a3b4248>"
    if mapping['collection']&.[]('join')
      self.parsed_metadata['collection'] = hyrax_record.member_of_collection_ids.join('; ')
      #   self.parsed_metadata['collection'] = hyrax_record.member_of_collections.map { |c| c.send(work_identifier)&.first }.compact.uniq.join(';')
    else
      hyrax_record.member_of_collections.each_with_index do |collection, i|
        self.parsed_metadata["collection_#{i + 1}"] = collection.id
        #     self.parsed_metadata["collection_#{i + 1}"] = collection.send(work_identifier)&.first
      end
    end

    build_files unless hyrax_record.is_a?(Collection)
    self.parsed_metadata
  end

  def build_mapping_metadata
    # OVERRIDE Bulkrax 1.0.2
    mapping.each do |key, value|
      next if Bulkrax.reserved_properties.include?(key) && !field_supported?(key)
      next if ['access_control_id', 'admin_set_id', 'model'].include?(key)
      next if value['excluded']

      object_key = key if value.key?('object')
      models = valid_attribute(hyrax_record, key)

      next unless models.present? || object_key.present?

      if object_key.present?
        # this will need to be updated if objects are ever used in the bulkrax mapping
        # build_object(value)
      else
        # always start a new model at index 1 so they align on the csv
        last_model = ''
        index = 1

        models.each do |model|
          next unless model
          index = last_model != model.class.to_s ? 1 : index + 1
          last_model = model.class.to_s

          build_value(model, key, value, index)
        end
      end
    end
  end

  def valid_attribute(hyrax_record, key)
    # we only want the models that have our current attribute. plus we need to retain the order
    # of the models so they are mapped properly in the build_value method
    models = []

    models << (model_responds_to(hyrax_record, key) ? hyrax_record : nil)

    hyrax_record.child_works&.each do |child_work|
      models << (model_responds_to(child_work, key) ? child_work : nil)

      child_work.child_works&.each do |grandchild_work|
        models << (model_responds_to(grandchild_work, key) ? grandchild_work : nil)
      end
    end

    models.sort_by! { |item| item.class.to_s }
  end

  def model_responds_to(model, key)
    # 'id' is not an attribute on a model, but we need to account for it
    key == 'id' || model.respond_to?(key.to_s) && model[key].present?
  end

  def build_value(current_record, key, value, index)
    # OVERRIDE Bulkrax 1.0.2
    model = current_record.class
    data = current_record.send(key.to_s)
    parsed_metadata["#{model}_#{index}"] ||= {}

    if data.is_a?(ActiveTriples::Relation)
      if value['join']
        self.parsed_metadata["#{model}_#{index}"][key_for_export(key, model)] = data.map { |d| prepare_export_data(d) }.join('| ')
      end
    elsif data
      self.parsed_metadata["#{model}_#{index}"][key_for_export(key, model)] = prepare_export_data(data)
    end
  end

  def key_for_export(key, model)
    # OVERRIDE Bulkrax 1.0.2
    clean_key = key_without_numbers(key)
    "#{model}.#{clean_key}"
  end

  def flatten_hash(data, initializer = {}, index = '')
    data.each_with_object(initializer) do |(key, value), hash|
      curation_concerns = ['Asset', 'Contribution', 'DigitalInstantiation', 'EssenceTrack', 'PhysicalInstantiation']
      model = key_without_numbers(key)

      if curation_concerns.include?(model)
        index = key.split('_').last
        hash[key] ||= ''
      end

      if value.is_a? Hash
        flatten_hash(value, hash, index)
      else
        index.present? ? hash["#{key}_#{index}"] = value : hash[key] = value
      end

      hash
    end
  end
end

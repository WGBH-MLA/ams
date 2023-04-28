# frozen_string_literal: true
# OVERRIDE Bulkrax 1.0.2

class CsvParser < Bulkrax::CsvParser
  attr_accessor :objects, :record_objects
  def records(_opts = {})
    # OVERRIDE Bulkrax 1.0.2
    file_for_import = only_updates ? parser_fields['partial_import_file_path'] : import_file_path
    # data for entry does not need source_identifier for csv, because csvs are read sequentially and mapped after raw data is read.
    csv_data = entry_class.read_data(file_for_import)
    csv_headers = csv_data.headers.map { |header| key_without_numbers(header) }
    invalid_headers = validate_csv_headers(csv_headers, file_for_import)
    raise_format_errors(invalid_headers) if invalid_headers.present?
    importer.parser_fields['total'] = csv_data.count
    importer.save
    @records ||= csv_data.map { |record_data| entry_class.data_for_entry(record_data, nil) }
  end

  def create_works
    # OVERRIDE Bulkrax 1.0.2
    self.record_objects = []
    records.each_with_index do |full_row, index|

      set_objects(full_row, full_row[:id]).each do |record|
        break if limit_reached?(limit, index)

        seen[record[work_identifier]] = true
        new_entry = find_or_create_entry(entry_class, record[work_identifier], 'Bulkrax::Importer', record.to_h.compact)
        if record[:delete].present?
          Bulkrax::DeleteWorkJob.send(perform_method, new_entry, current_run)
        else
          Bulkrax::ImportWorkJob.send(perform_method, new_entry.id, current_run.id)
        end
      end
      increment_counters(index)
    end
    importer.record_status
  rescue StandardError => e
    status_info(e)
  end

  def missing_elements(keys)
    # OVERRIDE Bulkrax 1.0.2
    required_elements.map(&:to_s) - keys.map(&:to_s) - ['title']
  end

  def setup_parents
    # OVERRIDE Bulkrax 1.0.2
    pts = []
    record_objects.each do |record|
      r = if record.respond_to?(:to_h)
            record.to_h
          else
            record
          end
      next unless r.is_a?(Hash)
      children = if r[:children].is_a?(String)
                   r[:children].split(/\s*[:;|]\s*/)
                 else
                   r[:children]
                 end
      next if children.blank?
      pts << {
        r[source_identifier] => children
      }
    end
    pts.blank? ? pts : pts.inject(:merge)
  end

  def collections
    # retrieve a list of unique collections
    records.map do |r|
      collections = []
      r[collection_field_mapping].split(/\s*[;|]\s*/).each { |title| collections << { title: title } } if r[collection_field_mapping].present?
      model_field_mappings.each do |model_mapping|
        collections << r if r[model_mapping.to_sym]&.downcase == 'collection'
      end
      collections
    end.flatten.compact.uniq
  rescue RuntimeError => e
    nil
  end

  def collections_total
    collections.present? ? collections.size : 0
  rescue RuntimeError => e
    nil
  end

  def works_total
    works.present? ? works.size : 0
  rescue RuntimeError => e
    nil
  end

  def works
    records - collections
  rescue RuntimeError => e
    nil
  end

  def create_new_entries
    current_work_ids.each_with_index do |wid, index|
      break if limit_reached?(limit, index)
      new_entry = find_or_create_entry(entry_class, wid, 'Bulkrax::Exporter')
      entry = Bulkrax::ExportWorkJob.perform_now(new_entry.id, current_run.id)

      self.headers |= entry.parsed_metadata.keys if entry
    end
  end

  # All possible column names
  def export_headers
    # OVERRIDE Bulkrax 1.0.2
    headers = sort_headers(self.headers)
    headers.delete('file') if headers.include?('file')

    headers.uniq
  end

  def sort_headers(headers)
    headers.sort_by! do |item|
      klass = ''
      attribute = ''
      index = ''

      if item.include? '.'
        klass, remainder = item.split('.')
        parts = remainder.split('_')
        index = parts.pop
        attribute = parts.join('_')
      elsif item.include? '_'
        klass, index = item.split('_')
      end

      order = if klass == 'Asset'
                1
              elsif klass == 'PhysicalInstantiation'
                2
              elsif klass == 'Contribution'
                3
              elsif klass == 'DigitalInstantiation'
                4
              elsif klass == 'EssenceTrack'
                5
      end

      "#{order}_#{index}_#{attribute}"
    end
  end

  private

  def validate_csv_headers(headers, file_for_import)
    csv_headers = headers - ['annotation', 'children', 'id', 'model', 'ref', 'source', 'version']
    unknown_headers = []

    csv_headers.sort.each do |key|
      unknown_headers << { message: "Unknown header: #{key}", filepath: "#{file_for_import}" } unless valid_header_key?(key.strip)
    end
    unknown_headers
  end

  def valid_header_key?(key)
    klass, value = key.split('.')
    object_class = klass if Hyrax.config.curation_concerns.include?(klass.constantize)
    extra_attr = if object_class == "Asset"
                  (AdminData.attribute_names.dup - ['created_at', 'updated_at'] +
                    Annotation.ingestable_attributes).uniq
                elsif object_class.include?("Instantiation")
                  (InstantiationAdminData.attribute_names.dup - ['created_at', 'updated_at'])
                end
    fedora_attr = object_class.constantize.properties.collect { |p| p.first.dup }.push('id'.dup)
    attr = extra_attr.nil? ? fedora_attr : fedora_attr.concat(extra_attr.deep_dup)
    attr.collect { |a| a.prepend(object_class + ".") }
    [[object_class] + attr].flatten.include?(key)
  end

  def raise_format_errors(invalid_headers)
    return unless invalid_headers.present?

    error_msg = invalid_headers.map do |failure|
      "#{failure[:message]}, in file: #{failure[:filepath]}"
    end
    raise "#{ error_msg.count == 1 ? error_msg.first : error_msg.join(" ****** ")}"
  end

  def set_objects(full_row, index)
    self.objects = []
    current_object = {}
    full_row = full_row.select { |k, v| !k.nil? }
    full_row_to_hash = full_row.to_hash
    asset_id = full_row_to_hash['Asset.id'].strip if full_row_to_hash.keys.include?('Asset.id')
    asset = Asset.find(asset_id) if asset_id.present?

    full_row_to_hash.keys.each do |key|
      standarized_key = key_without_numbers(key)
      # if the key is a Class, but not a property (e.g. "Asset", not "Asset.id")
      unless key.match(/\./)
        add_object(current_object.symbolize_keys)
        key_count = objects.select { |obj| obj[:model] == standarized_key }.count + 1
        bulkrax_identifier = full_row_to_hash["#{standarized_key}.bulkrax_identifier_#{key_count}"] || Bulkrax.fill_in_blank_source_identifiers.call(standarized_key, asset_id, key_count)
        asset = Asset.where(bulkrax_identifier: [bulkrax_identifier]).first if asset.nil?
        admin_data_gid = if standarized_key == 'Asset'
          if asset.present?
            asset.admin_data.update!(bulkrax_importer_id: importer.id)
            asset.admin_data_gid
          else
            AdminData.create(
              bulkrax_importer_id: importer.id
            ).gid
          end
        end

        current_object = {
          'model' => standarized_key,
          work_identifier.to_s => bulkrax_identifier,
          'title' => create_title(asset)
        }
        current_object.merge!({'admin_data_gid' => admin_data_gid}) if admin_data_gid
        next
      end

      klass, value = standarized_key.split('.')
      admin_data = AdminData.find_by_gid!(current_object['admin_data_gid']) if current_object['admin_data_gid'].present?
      annotation_type_values = AnnotationTypesService.new.select_all_options.to_h.transform_keys(&:downcase).values
      is_valid_annotation_type = annotation_type_values.include?(value)

      if is_valid_annotation_type
        set_annotations(admin_data, full_row_to_hash, standarized_key, value)
      elsif value == 'sonyci_id'
        set_sonyci_id(admin_data, full_row_to_hash[key])
      else
        raise "class key column is missing on row #{index}: #{full_row_to_hash}" unless klass == current_object['model']
        current_object[value] ||= full_row_to_hash[key]
      end
    end

    add_object(current_object.symbolize_keys)
  end

  def set_admin_data_bulkrax_importer_id(admin_data)
    return unless admin_data.present?

    admin_data.update(bulkrax_importer_id: importer.id)
  end

  def set_annotations(admin_data, full_row_to_hash, key, value)
    annotation = Annotation.find_by(annotation_type: value, admin_data: admin_data.id)

    if annotation.present?
      annotation.update(
        annotation: full_row_to_hash["Asset.annotation"] || nil,
        ref: full_row_to_hash["Asset.ref"] || nil,
        source: full_row_to_hash["Asset.source"] || nil,
        value: full_row_to_hash[key],
        version: full_row_to_hash["Asset.version"] || nil
      )
    else
      Annotation.create(
        admin_data_id: admin_data.id,
        annotation: full_row_to_hash["Asset.annotation"] || nil,
        annotation_type: value,
        ref: full_row_to_hash["Asset.ref"] || nil,
        source: full_row_to_hash["Asset.source"] || nil,
        value: full_row_to_hash[key],
        version: full_row_to_hash["Asset.version"] || nil
      )
    end
  end

  def set_sonyci_id(admin_data, key)
    admin_data.update(sonyci_id: [key])
  end

  def create_title(work = nil)
    asset = objects.first
    return unless asset

    work.present? ? "#{work.series_title.first}; #{work.episode_title.first}" : "#{asset[:series_title]}; #{asset[:episode_title]}"
  end

  def add_object(current_object)
    if current_object.present?
      if objects.first
        objects.first[:children] ||= []
        objects.first[:children] << current_object[work_identifier]
      end
      record_objects << current_object
      objects << current_object
    end
  end
end

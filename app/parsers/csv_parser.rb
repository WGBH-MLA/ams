# frozen_string_literal: true

class CsvParser < Bulkrax::CsvParser
  attr_accessor :objects, :record_objects
  def create_works
    self.record_objects = []
    records.each_with_index do |full_row, index|
      set_objects(full_row, index).each do |record|
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
    required_elements.map(&:to_s) - keys.map(&:to_s) - ['title']
  end

  def setup_parents
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

  private

  def set_objects(full_row, index)
    self.objects = []
    current_object = {}
    full_row = full_row.select {|k, v| !k.nil? }
    full_row_to_hash = full_row.to_hash
    asset_id = full_row_to_hash['Asset.id'].strip if full_row_to_hash.keys.include?('Asset.id')
    work = Asset.find(asset_id) if asset_id.present?

    full_row_to_hash.keys.each do |key|
      # if the key is a Class, but not a property (e.g. "Asset", not "Asset.id")
      if !key.match(/\./)
        add_object(current_object.symbolize_keys)
        key_count = objects.select { |obj| obj['model'] == key }.size + 1
        admin_data_gid = if key == 'Asset'
          if work.present?
            work.admin_data_gid
          else
            AdminData.create.gid
          end
        end
        current_object = {
          'model' => key,
          work_identifier.to_s => Bulkrax.fill_in_blank_source_identifiers.call(self, "#{key}-#{index}-#{key_count}"),
          'title' => create_title(work)
        }
        current_object.merge!({'admin_data_gid' => admin_data_gid}) if admin_data_gid
        next
      end

      klass, value = key.split('.')
      admin_data = AdminData.find_by_gid(current_object['admin_data_gid'])
      annotation_type_values = AnnotationTypesService.new.select_all_options.to_h.transform_keys(&:downcase).values
      is_valid_annotation_type = annotation_type_values.include?(value)

      if is_valid_annotation_type
        set_annotations(admin_data, full_row_to_hash, key, value)
      elsif value == 'sonyci_id'
        set_sonyci_id(admin_data, full_row_to_hash[key])
      else
        raise "class key column is missing on row #{index}: #{full_row_to_hash}" unless klass == current_object['model']
        current_object[value] = full_row_to_hash[key]
      end
    end

    add_object(current_object.symbolize_keys)
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

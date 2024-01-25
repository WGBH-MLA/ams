# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    case self.parsed_metadata['model']
    when 'DigitalInstantiationResource'
        add_digital_metadata
    when 'PhysicalInstantiationResource'

      add_physical_metadata
    when 'AssetResource'
      add_asset_metadata
    end
  end

  def add_asset_metadata
    self.parsed_metadata["contributors"] = self.raw_metadata["contributors"]
    self.parsed_metadata['bulkrax_importer_id'] = importer.id
    self.parsed_metadata['admin_data_gid'] = admin_data_gid
    self.parsed_metadata['sonyci_id'] = self.raw_metadata['sonyci_id']
    build_annotations(self.raw_metadata['annotations']) if self.raw_metadata['annotations'].present?
  end

  def add_digital_metadata
    add_instantiation_metadata
    self.parsed_metadata['pbcore_xml'] = self.raw_metadata['pbcore_xml'] if self.raw_metadata['pbcore_xml'].present?

    self.parsed_metadata['skip_file_upload_validation'] = self.raw_metadata['skip_file_upload_validation'] if self.raw_metadata['skip_file_upload_validation'] == true
  end

  def add_physical_metadata
    add_instantiation_metadata
  end

  def add_instantiation_metadata
    self.parsed_metadata['format'] = self.raw_metadata['format']
  end

  def admin_data
    return @admin_data if @admin_data.present?
    asset_resource_id = self.raw_metadata['Asset.id'].strip if self.raw_metadata.keys.include?('Asset.id')
    asset_resource_id ||= self.raw_metadata['id']
    begin
      work = Hyrax.query_service.find_by(id: asset_resource_id) if asset_resource_id
    rescue Valkyrie::Persistence::ObjectNotFoundError
      work = nil
    end

    @admin_data = work.admin_data if work.present?
    @admin_data ||= AdminData.find_by_gid(self.raw_metadata['admin_data_gid']) if self.raw_metadata['admin_data_gid'].present?
    @admin_data ||= AdminData.new
    @admin_data.bulkrax_importer_id = importer.id
    @admin_data.save
    @admin_data
  end

  def admin_data_gid
    admin_data.gid
  end

  def build_annotations(annotations)
    annotations.each do |annotation|
      if annotation['annotation_type'].nil?
        raise "annotation_type not registered with the AnnotationTypesService: #{annotation['annotation_type']}."
      end

      Annotation.find_or_create_by(
        annotation_type: annotation['annotation_type'],
        source: annotation['source'],
        value: annotation['value'],
        annotation: annotation['annotation'],
        version: annotation['version'],
        admin_data_id: admin_data.id
      )
    end
  end
end

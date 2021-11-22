class PbcoreXmlParser < Bulkrax::XmlParser
  include Bulkrax::PbcoreParserBehavior
  attr_accessor :objects, :record_objects

  def create_works
    self.record_objects = []
    records.each_with_index do |file, index|
      set_objects(file, index).each do |record|
        break if limit_reached?(limit, index)
        record = set_digital_instantiation_children(record) if record[:model] == 'DigitalInstantiation'
        seen[record[work_identifier]] = true
        new_entry = find_or_create_entry(entry_class, record[work_identifier], 'Bulkrax::Importer', record.compact)
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
        r[work_identifier] => children
      }
    end
    pts.blank? ? pts : pts.inject(:merge)
  end

  private

  def set_objects(file, index)
    self.objects = []
    current_object = {}
    new_rows = []
    instantiations = PBCore::DescriptionDocument.parse(file[:data]).instantiations
    pbcore_physical_instantiations = instantiations.select { |inst| inst.physical }
    pbcore_digital_instantiations = instantiations.select { |inst| inst.digital }
    tracks = instantiations.map(&:essence_tracks).flatten # processed in the digitial inst. actor. if we comment this out it will not
    # show up in the bulkrax importer, but the records still get processed in the actor.
    # people/contributor is processed as part of the asset_attributes method
    new_rows += parse_rows([AAPB::BatchIngest::PBCoreXMLMapper.new(file[:data]).asset_attributes.merge!({ delete: file[:delete] })], 'Asset', index)
    new_rows += parse_rows(pbcore_physical_instantiations.map { |inst| AAPB::BatchIngest::PBCoreXMLMapper.new(inst.to_xml).physical_instantiation_attributes }, 'PhysicalInstantiation', index)
    new_rows += parse_rows(pbcore_digital_instantiations.map { |inst| AAPB::BatchIngest::PBCoreXMLMapper.new(inst.to_xml).digital_instantiation_attributes.merge!({ pbcore_xml: inst.to_xml, skip_file_upload_validation: true }) }, 'DigitalInstantiation', index)
    new_rows += parse_rows(tracks.map { |track| AAPB::BatchIngest::PBCoreXMLMapper.new(track.to_xml).essence_track_attributes }, 'EssenceTrack', index)

    new_rows
  end
end
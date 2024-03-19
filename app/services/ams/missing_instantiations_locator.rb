# frozen_string_literal: true
require 'ruby-progressbar'

module AMS
  class MissingInstantiationsLocator
    WORKING_DIR = Rails.root.join('tmp', 'imports')

    attr_reader :search_dir, :results_path, :results

    # TODO: take array of directory paths?
    def initialize(search_dir:)
      @search_dir = WORKING_DIR.join(search_dir)
      @results_path = WORKING_DIR.join("i16-#{search_dir}.json")
      @results = initialize_results
    end

    # TODO: better method name
    def locate_within_dir
      xml_files = Dir.glob(search_dir.join('*.xml'))

      xml_files.each do |f|
        locate(f)
      end

      write_results
    end

    # TODO: better method name
    def locate(xml_file)
      xml = File.read(xml_file)

      pbcore_id = xml.scan(/(cpb-aacip\/.+?)<\//).flatten.first
      asset_id = pbcore_id.tr('/', '-')
      instantiation_identifiers = xml.scan(/<instantiationIdentifier .+?>(.+?)<\/instantiationIdentifier>/mi).flatten

      instantiation_identifiers.each do |inst_id|
        instantiation_class = xml.match?('instantiationPhysical') ? PhysicalInstantiation : DigitalInstantiation
        af_instantiations = instantiation_class.where(local_instantiation_identifier: inst_id)

        broken = af_instantiations.any? do |af_inst|
          normalize_date(af_inst.date_uploaded) != normalize_date(af_inst.date_modified)
        end
        next unless broken

        results[inst_id] ||= []
        results[inst_id] |= Array.wrap(asset_id)
      end
    end

    def normalize_date(date)
      date.to_datetime.strftime('%Y-%m-%d %H:%M')
    end

    def initialize_results
      if File.exist?(results_path)
        JSON.parse(File.read(results_path))
      else
        {}
      end
    end

    def write_results
      File.open(results_path, 'w') do |f|
        f.puts results.to_json
      end
    end
  end
end

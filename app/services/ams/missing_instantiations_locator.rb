# frozen_string_literal: true
require 'ruby-progressbar'

module AMS
  class MissingInstantiationsLocator
    WORKING_DIR = Rails.root.join('tmp', 'imports')

    attr_reader :search_dirs, :current_dir, :results_path, :results, :progressbar

    # @param [Array<String>] search_dirs
    def initialize(search_dirs)
      @search_dirs = search_dirs.map { |dir| WORKING_DIR.join(dir) }
    end

    # TODO: better method name
    def locate_within_dirs
      search_dirs.each do |current_dir|
        @current_dir = current_dir
        @results_path = WORKING_DIR.join("i16-#{truncated_dir_name(current_dir)}.json")
        @results = initialize_results
        xml_files = Dir.glob(current_dir.join('*.xml'))
        progressbar_format = "#{truncated_dir_name(current_dir)} -- %a %e %P% Processed: %c from %C"
        @progressbar = ProgressBar.create(total: xml_files.size, format: progressbar_format)

        xml_files.each do |f|
          locate(f)
          progressbar.increment
        end

        write_results
      end
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
        results[inst_id] |= Array.wrap("#{truncated_dir_name(current_dir)}/#{asset_id}")
      end
    end

    def normalize_date(date)
      date.to_datetime.strftime('%Y-%m-%d %H:%M')
    end

    def truncated_dir_name(dir)
      dir.to_s.split('/').last
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

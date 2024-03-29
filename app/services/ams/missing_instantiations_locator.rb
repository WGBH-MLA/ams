# frozen_string_literal: true
require 'ruby-progressbar'

module AMS
  # @see https://github.com/scientist-softserv/ams/issues/16
  class MissingInstantiationsLocator
    WORKING_DIR = Rails.root.join('tmp', 'imports')

    attr_reader :search_dirs, :current_dir, :truncated_dir_name, :results_path, :results, :progressbar, :logger

    # @param [Array<String>] search_dirs
    def initialize(search_dirs)
      @search_dirs = search_dirs.map { |dir| WORKING_DIR.join(dir) }
      @logger = ActiveSupport::Logger.new(
        WORKING_DIR.join('i16-missing-instantiations-locator.log')
      )
    end

    def map_all_instantiation_identifiers
      search_dirs.each do |current_dir|
        @current_dir = current_dir
        @truncated_dir_name = File.basename(current_dir)
        @results_path = WORKING_DIR.join("i16-#{truncated_dir_name}.json")
        @results = initialize_results
        xml_files = Dir.glob(current_dir.join('*.xml'))
        progressbar_format = "#{truncated_dir_name} -- %a %e %P% Processed: %c from %C"
        @progressbar = ProgressBar.create(total: xml_files.size, format: progressbar_format)

        logger.info("Starting #{truncated_dir_name}")

        xml_files.each do |f|
          map_asset_id_to_inst_ids(f)
          progressbar.increment
        end

        write_results
      rescue => e
        logger.error("#{e.class} (#{truncated_dir_name}) - #{e.message}")
      end
    end

    private

    def map_asset_id_to_inst_ids(xml_file)
      xml = File.read(xml_file)
      current_file_path = "#{truncated_dir_name}/#{File.basename(xml_file)}"

      pbcore_id = xml.scan(/(cpb-aacip\/.+?)<\//).flatten.first
      if pbcore_id.blank?
        logger.debug("No pbcore_id found within #{current_file_path}")
        return
      end
      asset_id = pbcore_id.tr('/', '-')
      instantiation_identifiers = xml.scan(/<instantiationIdentifier .+?>(.+?)<\/instantiationIdentifier>/mi).flatten
      if instantiation_identifiers.blank?
        logger.debug("No instantiation identifier(s) found within #{current_file_path}")
        return
      end

      instantiation_identifiers.each do |inst_id|
        instantiation_class = xml.match?('instantiationPhysical') ? PhysicalInstantiation : DigitalInstantiation
        af_instantiations = instantiation_class.where(local_instantiation_identifier: inst_id)

        broken = af_instantiations.any? do |af_inst|
          normalize_date(af_inst.date_uploaded) != normalize_date(af_inst.date_modified)
        end
        next unless broken

        results[inst_id] ||= []
        results[inst_id] |= Array.wrap("#{truncated_dir_name}/#{asset_id}")
      rescue => e
        logger.error("#{e.class} (#{current_file_path}) (Inst: #{inst_id}) - #{e.message}")
      end
    rescue => e
      logger.error("#{e.class} (#{current_file_path}) - #{e.message}")
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

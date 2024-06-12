# frozen_string_literal: true
require 'ruby-progressbar'
require 'parallel'

module AMS
  # @see https://github.com/scientist-softserv/ams/issues/16
  class MissingInstantiationsLocator # rubocop:disable Metrics/ClassLength
    WORKING_DIR = Rails.root.join('tmp', 'imports')

    attr_reader :current_dir, :truncated_dir_name, :results_path, :results, :progressbar, :logger

    def initialize
      @logger = Logger.new(WORKING_DIR.join('i16-missing-instantiations-locator.log'))
    end

    # @param [Array<String>] search_dirs
    def map_all_instantiation_identifiers(search_dirnames)
      search_dirs = search_dirnames.map { |dir| WORKING_DIR.join(dir) }
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

    def merge_all_instantiation_maps
      results_files = Dir.glob(WORKING_DIR.join('i16-AMS1Importer*.json'))
      base_hash = JSON.parse(File.read(results_files.shift))
      progressbar = ProgressBar.create(total: results_files.size, format: '%a %e %P% Processed: %c from %C')

      results_files.each do |file|
        merging_hash = JSON.parse(File.read(file))
        base_hash.merge!(merging_hash) do |_inst_id, base_asset_ids, merging_asset_ids|
          base_asset_ids | merging_asset_ids
        end
        progressbar.increment
      end

      File.open(WORKING_DIR.join('i16-combined-results.json'), 'w') do |file|
        file.puts base_hash.to_json
      end
    end

    # @param [Integer] num_processes
    def create_subsets_from_merged_map(num_processes: 4)
      results = JSON.parse(File.read(WORKING_DIR.join('i16-combined-results.json')))
      uniq_asset_paths = results.values.flatten.uniq
      subsets = uniq_asset_paths.each_slice(10_000).to_a

      Parallel.each_with_index(subsets, in_processes: num_processes) do |set, i|
        set_path = WORKING_DIR.join("i16-subset-#{i}")
        FileUtils.mkdir_p(set_path)
        pb_format = "Copying XML files to #{File.basename(set_path)}: %a %e %c/%C %P%"
        progressbar = ProgressBar.create(total: set.size, format: pb_format)

        set.each do |asset_path|
          importer_dir, asset_id = asset_path.split('/')
          xml_filename = "#{asset_id.sub('cpb-aacip-', '')}.xml"

          if File.exist?(WORKING_DIR.join(set_path, xml_filename))
            logger.debug "#{xml_filename} already exists in #{File.basename(set_path)}"
          else
            begin
              FileUtils.cp(WORKING_DIR.join(importer_dir, xml_filename), WORKING_DIR.join(set_path, xml_filename))
            rescue => e
              logger.error "#{e.class} - (#{File.basename(set_path)}/#{xml_filename}) - #{e.message}"
            end
          end
          progressbar.increment
        end
      end
    end

    def audit_duplicate_xml_files
      results = JSON.parse(File.read(WORKING_DIR.join('i16-combined-results.json')))
      asset_paths = results.values.flatten.uniq
      filename_map = {}

      asset_paths.each do |path|
        path, asset_id = path.split('/')
        filename = "#{asset_id.sub('cpb-aacip-', '')}.xml"

        filename_map[filename] ||= {}
        filename_map[filename][:paths] ||= []
        filename_map[filename][:paths] << path
      end

      duplicate_files = filename_map.select { |_filename, attrs| attrs[:paths].size > 1 }

      duplicate_files.each do |filename, attrs|
        file_contents = attrs[:paths].map { |path| File.read(WORKING_DIR.join(path, filename)) }
        duplicate_files[filename][:content_differs] = file_contents.uniq.size > 1
      end

      File.open(WORKING_DIR.join('i16-duplicate-xml-files-audit.json'), 'w') do |file|
        file.puts JSON.pretty_generate(duplicate_files)
      end
    end

    def destroy_assets(subset_path)
      xml_files = Dir.glob(subset_path.join('*.xml'))
      asset_ids = xml_files.map { |f| "cpb-aacip-#{File.basename(f).sub('.xml', '')}" }

      begin
        logger.info "Destroying #{asset_ids.size} Assets via the AssetDestroyer. See asset_destroyer.log"
        ad = AMS::AssetDestroyer.new(asset_ids: asset_ids, user_email: 'wgbh_admin@wgbh-mla.org')
        ad.destroy(ad.asset_ids)
      rescue => e
        logger.error "Error destroying Assets. See asset_destroyer.log (#{e.class} - #{e.message})"
      end
    end

    def create_subset_importers
      subset_paths = Dir.glob(Rails.root.join('tmp', 'imports', 'i16-subset*'))
      base_imp = Bulkrax::Importer.find_by(name: 'AMS1Importer_0-10000')
      desired_parser_field_attrs = %w[
        record_element
        import_type
        visibility
        rights_statement
        override_rights_statement
        file_style
      ]

      subset_paths.each do |path|
        imp = base_imp.dup

        imp.name = File.basename(path)
        imp.parser_fields = base_imp.parser_fields.slice(*desired_parser_field_attrs)
        imp.parser_fields['import_file_path'] = path.to_s

        imp.save!
      end
    end

    def export_assets
      results = JSON.parse(File.read(WORKING_DIR.join('i16-combined-results.json')))
      uniq_asset_paths = results.values.flatten.uniq
      ids = uniq_asset_paths.map { |path| path.split('/')[1] }

      query = 'has_model_ssim:Asset'
      fq = ids.join(' OR ')
      df = 'id'
      rows = 375_000
      solr_docs = Hyrax::SolrService.query(query, fq: fq, df: df, rows: rows)

      hash = {}
      solr_docs.each do |doc|
        hash[doc['id']] = doc
      end

      File.open(WORKING_DIR.join('i16-asset-data-export.json'), 'w') do |f|
        f.puts hash.to_json
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

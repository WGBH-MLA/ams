namespace :ams do
  desc 'Migrate Fedora records out of "hard-coded" location'
  task migrate_old_guids: :environment do
    require 'ruby-progressbar'

    client = Blacklight.default_index.connection
    start_date = Date.new(2000, 1, 1)
    end_date = Date.new(2022, 11, 27)
    models = %w[Asset PhysicalInstantiation DigitalInstantiation EssenceTrack]
    query = "system_create_dtsi:[#{start_date.strftime('%Y-%m-%dT00:00:00Z')} TO #{end_date.strftime('%Y-%m-%dT23:59:59Z')}] " \
            "has_model_ssim:(#{models.join(' OR ')})"
    params = {
      q: query,
      fl: 'id',
      sort: 'system_create_dtsi asc',
      rows: 2_147_483_647,
      wt: 'json'
    }

    response = client.post('select', params: params)
    total = response['response']['numFound']
    raise StandardError, "No Solr documents found matching query: #{query}" if total.zero?

    docs = response['response']['docs']
    ids = docs.map { |doc| doc['id'] }
    progressbar = ProgressBar.create(total: total, format: '%a %e %P% Processed: %c from %C')
    logger = ActiveSupport::Logger.new('tmp/imports/migrate_old_guids.log')
    ids_file_path = 'tmp/imports/migrate_old_guids_ids.txt'

    FileUtils.rm(ids_file_path) if File.exist?(ids_file_path)
    File.open(ids_file_path, 'w') do |file|
      ids.each do |id|
        file.puts(id)
      end
    end

    begin
      ids.each do |id|
        logger.info("Starting #{id}")
        new_uri = "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{::Noid::Rails.treeify(id)}"
        new_location_ping = %x{curl -I #{new_uri} 2> /dev/null}

        if new_location_ping.match?('200 OK')
          logger.debug("#{id} already exists at #{new_uri}, skipping...")
          progressbar.increment
          next
        end

        old_uri = "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{::Noid::Rails.treeify(id, false)}"
        new_uri_path = new_uri.sub(/\w+-\w+-\w+$/, '')
        %x{curl -X PUT "#{new_uri_path}" > /dev/null 2>&1}
        %x{curl -X MOVE -H "Destination: #{new_uri}" "#{old_uri}" > /dev/null 2>&1}

        progressbar.increment
      end
    rescue => e
      logger.error("#{e.class} | #{e.message} | #{id} | Continuing...")
    end
  end
end

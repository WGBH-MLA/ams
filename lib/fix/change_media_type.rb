require_relative '../../config/environment'
require_relative 'batch_process'

module Fix
  class ChangeMediaType < BatchProcess
    MEDIA_TYPES = MediaTypeService.new.select_all_options.to_h.values

    attr_reader :media_type

    def initialize(media_type:, **args)
      super(**args)
      raise ArgumentError, "media_type must be one of '#{MEDIA_TYPES.join("', '")}', but '#{media_type}' was given" unless MEDIA_TYPES.include?(media_type)
      @media_type = media_type
    end
    
    option_parser do |opts|
      opts.banner = "Usage: ruby lib/fix/change_media_type.rb [options]"

      opts.on("-t", "--media-type MEDIA_TYPE", "Either 'Sound' or 'Movind Image'") do |media_type|
        cli_options[:media_type] = media_type
      end
    end

    def run
      log.info "Running fix #{self.class.name} ..."
      asset_resources.each do |ar|
        if ar.physical_instantiation_resources.count == 0
          log.warn "No Physical Instantiations for Asset Resource #{ar.id}, skipping."
          next
        end

        pi = ar.physical_instantiation_resources.detect  { |pi| pi.media_type != media_type }
        if !pi
          log.warn "Asset Resource #{ar.id} has no Physical Instantiations without media type of #{media_type}, skipping."
          next
        end

        # Change the metadata
        pi.media_type = media_type

        begin
          pi.save
          log.info "Physical Instantiation #{pi.id} for Asset Resource #{ar.id} saved with media_type '#{media_type}'"
        rescue => e
          log_error e
        end
      end
      log.info "Done."
    end
  end
end


if __FILE__ == $0
  Fix::ChangeMediaType.run_cli
end

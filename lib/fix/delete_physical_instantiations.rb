require 'optparse'
require_relative '../../config/environment'
require_relative 'batch_process'

module Fix
  class DeletePhysicalInstantiations < BatchProcess
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
      asset_resources.each do |ar|
        pis = ar.physical_instantiation_resources.select { |pi| pi.media_type == media_type }
        if pis.count == 0
          log.warn "No physical instantiations with media type '#{media_type}' were found for Asset #{ar.id}, skipping."
          next
        end

        pis.each do |pi|
          begin
            log.info "Deleting Physical Instantiation #{pi.id} with media type '#{media_type}' from Asset #{ar.id}..."
            Hyrax.persister.delete(resource: pi)
            Hyrax.index_adapter.delete(resource: pi)
            log.info "Deleted physical instantiation #{pi.id} with media type '#{media_type}' from Asset #{ar.id}."
            Hyrax.index_adapter.save(resource: ar)
            log.info "Asset Resource #{ar.id} saved."
          rescue => e
            log_error(e)
          end
        end
      end
    end
  end
end


if __FILE__ == $0
  Fix::DeletePhysicalInstantiations.run_cli
end

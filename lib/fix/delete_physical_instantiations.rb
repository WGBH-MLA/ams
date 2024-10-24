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
        process_asset_resource(ar)
      end
    end

    private

    def process_asset_resource(ar)
      log.info "Processing Asset Resource #{ar.id}..."
      pis = ar.physical_instantiation_resources.select { |pi| pi.media_type == media_type }
      if pis.count == 0
        log.warn "SKIPPING: No physical instantiations with media type '#{media_type}'."
        return
      end

      pis.each do |pi|
        delete_physical_instantiation_resource(pi)
        ar.members.delete(pi)
      end

      Hyrax.index_adapter.save(resource: ar)
      log.info "SAVED: Asset Resource #{ar.id}."
    rescue => e
      log_error(e)
    end

    def delete_physical_instantiation_resource(pi)
      Hyrax.persister.delete(resource: pi)
      delete_from_fedora(pi)
      Hyrax.index_adapter.delete(resource: pi)
      log.info "DELETED: Physical Instantiation Resource #{pi.id} with media type '#{media_type}'"
    rescue => e
      log_error(e)
    end

    def delete_from_fedora(pi)
      log.info "SEARCHING: PhysicalInstantiation #{pi.id} in Fedora..."
      pi = PhysicalInstantiation.find(pi.id)
      pi.destroy!
      log.info "DELETED: PhysicalInstantiation #{pi.id} from Fedora."
    rescue ActiveFedora::ObjectNotFoundError
      log.info "NOT FOUND."
    rescue => e
      log_error(e)
    end
  end
end


if __FILE__ == $0
  Fix::DeletePhysicalInstantiations.run_cli
end

require_relative '../../config/environment'
require_relative 'batch_process'

module Fix
  class DeleteAssetResources < BatchProcess
    def run
      asset_resources.each do |ar|
        log.info "Destroying Asset Resource #{ar.id}"
        begin
          Hyrax.persister.delete(resource: ar)
          Hyrax.index_adapter.delete(resource: ar)
          Hyrax.index_adapter.connection.commit
          log.info "Asset Resource #{ar.id} destroyed."
        rescue => e
          log_error e
        end
      end
      puts "Done."
    end
  end
end

if __FILE__ == $0
  Fix::DeleteAssetResources.run_cli
end

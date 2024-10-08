require_relative '../../config/environment'
require_relative 'batch_process'

module Fix
  class DeleteAssetResources < BatchProcess
    def run
      puts "This script is buggy, needs fixed"
      # NOTE: after using this script to delete assets, and then trying to re-ingest, I got this error:
      # PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "idx_20533_sipity_entities_proxy_for_global_id"
      # So something additional needs to be run to this artifact and any others. Probably a method to do this, but need to find it.
      # Until then, disabling this script, but keeping the logic commented out.
      
      # asset_resources.each do |ar|
      #   log.info "Destroying Asset Resource #{ar.id}"
      #   begin
      #     Hyrax.persister.delete(resource: ar)
      #     Hyrax.index_adapter.delete(resource: ar)
      #     Hyrax.index_adapter.connection.commit
      #     log.info "Asset Resource #{ar.id} destroyed."
      #   rescue => e
      #     log_error e
      #   end
      # end
      # puts "Done."
    end
  end
end

if __FILE__ == $0
  Fix::DeleteAssetResources.run_cli
end

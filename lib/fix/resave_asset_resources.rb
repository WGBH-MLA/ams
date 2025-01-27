require_relative '../../config/environment'
require_relative 'batch_process'

module Fix
  class ResaveAssetResources < BatchProcess

    def run
      log.info "Resaving #{asset_resources.count} Asset Resources..."
      asset_resources.each do |ar|
        resave_asset_resource(resource: ar)
      end
      log.info "Done."
      log.info report
    end

    private

    def results; @results ||= []; end

    def resave_asset_resource(resource:)
      result = { resource: resource }
      log.info "RESAVING #{resource.class} #{resource.id.id}..."
      resource.set_validation_status
      Hyrax.persister.save(resource: resource)
      Hyrax.index_adapter.save(resource: resource)
      log.info "SAVED #{resource.class} #{resource.id.id}."
      results << result
    rescue => e
      result[:error] = e
      results << result
      log_error e
    end

    def report
      r = "\nRESULTS:\n"
      r += "Successfully saved #{successes.count}:\n"
      successes.each do |result|
        r += "#{result[:resource].id}, #{result[:resource].class}\n"
      end
      r += "Failed while saving #{failures.count}:\n"
      failures.each do |result|
        r += "#{result[:resource].id}, #{result[:error]}\n"
      end
      r
    end

    def successes; results.reject  { |r| r[:error] }; end
    def failures;  results.select { |r| r[:error] }; end
  end
end

if __FILE__ == $0
  Fix::ResaveAssetResources.run_cli
end

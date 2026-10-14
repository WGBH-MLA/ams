require_relative '../../config/environment'
require_relative 'batch_process'

module Fix
  class DeleteAssetResources < BatchProcess

    def run
      log.info "Deleting #{asset_resources.count} Asset Resources..."
      asset_resources.map do |ar|
        destroy_work_and_members(resource: ar)
      end
      log.info "Done."
      log.info report
    end

    private


    def results; @results ||= []; end

    def work_destroy_transaction
      Hyrax::Transactions::WorkDestroy.new
    end

    def destroy_work_and_members(resource:)
      result = { resource: resource }

      resource.members.each do |member|
        destroy_work_and_members(resource: member)
      end

      log.info "DELETING #{resource.class} #{resource.id.id}..."
      work_destroy_transaction.call(resource)
      log.info "DELETED #{resource.class} #{resource.id.id}."
      result[:error] = false
      results << result
    rescue => e
      result[:error] = e
      results << result
      log_error e
    end

    def report
      r = "\nRESULTS:\n"
      r += "Successfully Deleted #{successes.count}:\n"
      successes.each do |result|
        r += "#{result[:resource].id}, #{result[:resource].class}\n"
      end
      r += "Failed while Deleting #{failures.count}:\n"
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
  Fix::DeleteAssetResources.run_cli
end

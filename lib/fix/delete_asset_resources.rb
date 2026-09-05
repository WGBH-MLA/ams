require_relative '../../config/environment'
require_relative 'batch_process'
require 'parallel'

module Fix
  class DeleteAssetResources < BatchProcess

    BATCH_SIZE = 100 # adjust based on memory
    THREADS = 5      # number of parallel threads

    def run
      total = asset_resources.count
      log.info "Deleting #{total} Asset Resources..."

      @processed_count = 0

      # Process in batches to avoid memory issues
      asset_resources.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        # Parallelize within each batch
        Parallel.each(batch, in_threads: THREADS) do |resource|
          destroy_work_and_members(resource)
        end

        @processed_count += batch.size
        log.info "Progress: #{@processed_count}/#{total} resources deleted"
        puts "Progress: #{@processed_count}/#{total} resources deleted"
      end

      log.info "Done."
      log.info report
      puts "Done."
    end

    private

    def results
      @results ||= []
    end

    def work_destroy_transaction
      Hyrax::Transactions::WorkDestroy.new
    end

    def destroy_work_and_members(resource)
      result = { resource: resource }

      # Recursively destroy members if any
      resource.members.each do |member|
        destroy_work_and_members(member)
      end

      # Destroy work
      work_destroy_transaction.call(resource)

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
      successes.each { |res| r += "#{res[:resource].id}, #{res[:resource].class}\n" }
      r += "Failed while Deleting #{failures.count}:\n"
      failures.each { |res| r += "#{res[:resource].id}, #{res[:error]}\n" }
      r
    end

    def successes
      results.reject { |r| r[:error] }
    end

    def failures
      results.select { |r| r[:error] }
    end
  end
end

if __FILE__ == $0
  Fix::DeleteAssetResources.run_cli
end

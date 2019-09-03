require 'ams/sidekiq_process_manager'

# Rake tasks to verify services are running.
# The script at bin/deploy/verify_service.sh is executed as part the
# ValidateService hook provided by CodeDeploy (see appspec.yml in project root).
# These rake tasks are used by that script to verify that services are running.
# Using ruby makes is more organized and easier to read.
namespace :verify_service do
  task :sidekiq do
    active_pids = AMS::SidekiqProcessManager.new.active_pids
    raise 'Sidekiq is not running' unless active_pids.count > 0
    puts "#{active_pids.count} Sidekiq process running."
  end

  task :homepage do
    host = ENV.fetch('PRODUCTION_HOST')
    result = `curl -s -o /dev/null -I -w "%{http_code}" #{host}`
    msg = "Request to #{host} returned: #{result}"
    raise msg unless result == '200'
    puts msg
  end
end

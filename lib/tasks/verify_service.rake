require 'ams/toggle_sidekiq'

# Rake tasks to verify services are running.
# The script at bin/deploy/verify_service.sh is executed as part the
# ValidateService hook provided by CodeDeploy (see appspec.yml in project root).
# These rake tasks by that script to verify that services are running. Using
# ruby makes is more organized and easier to read.
namespace :verify_service do
  task :sidekiq do
    sidekiq_pids = AMS::ToggleSidekiq.new.sidekiq_pids
    raise 'Sidekiq is not running' unless sidekiq_pids.count > 0
    puts "#{sidekiq_pids.count} Sidekiq process running."
  end

  task :homepage do
    host = ENV.fetch('PRODUCTION_HOST')
    result = `curl -s -o /dev/null -I -w "%{http_code}" #{host}`
    msg = "Request to #{host} returned: #{result}"
    raise msg unless result == '200'
    puts msg
  end
end

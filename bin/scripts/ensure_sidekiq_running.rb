require_relative '../../lib/ams/sidekiq_process_manager.rb'

sidekiq = AMS::SidekiqProcessManager.new
puts "#{sidekiq.active_pids.count} Sidekiq processes running."

# If the reset flag was set, turn Sidekiq off first, and make sure no
# processes are running before continuing.
if ENV.fetch('SIDEKIQ_RESET', false)
  # Here we specify a long wait time of 5 min. This should be at least as much
  # as the timeout specified in Sidekiq config.
  sidekiq.turn_off wait: 300
  if sidekiq.running?
    puts "Could not reset Sidekiq processes. You may need to increase the " \
         "timeout in the Sidekiq config file, check logs for errors during " \
         "shutdown, and/or manually restart Sidekiq."
    exit 1
  end
end


sidekiq.ensure_on(count: 1)

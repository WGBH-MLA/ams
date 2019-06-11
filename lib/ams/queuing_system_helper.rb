module AMS
  # Helper class to start/stop Sidekiq processes.
  # This is specific to running sidekiq processes on web machine. If our queuing
  # service changes, this will need changing too.
  class QueuingServiceHelper
    def running_processes
      # @runnning_processes  ||= Use shell command to get running PIDs.
      # ps aux | grep sidekiq | cut stuff
    end

    def kill_running_processes
      running_processes.each do |pid|
        # kill pid
      end
    end

    def restart(num=3)
      num.times do
        # shell command to start processes
        # bundle exec sidekiq -e #{RAILS.env} > log/sidekiq.log 2>&1 &
      end
    end
  end
end

require 'sidekiq/api'
require 'open3'
require 'logger'

module AMS
  class SidekiqProcessManager

    def running?; active_pids.count > 0; end

    def turn_on(count: 1, wait: 45)
      count = [count.to_i, 0].max
      logger.info "Turning on #{count} new Sidekiq processes; #{active_pids.count} currently running..."
      new_total = count + active_pids.count

      # Start the specified number of new sidekiq processes. This will spawn new
      # processes to run in the background.
      start_sidekiq_processes(count: count)

      # Wait for all the processes to start.
      try_until(wait) { active_pids.count == new_total }

      # Log a message telling whether all processes have started, or whether
      # some are still trying to start, or may have errored.
      if active_pids.count < new_total
        logger.warn "Waited #{wait} seconds for #{new_total} processes " \
                    "to be running, but #{active_pids.count} are currently " \
                    "running. You may need to just wait longer, or check " \
                    "#{sidekiq_log_file} for possible errors during startup."
      else
        logger.info "#{active_pids.count} Sidekiq processes running."
      end
    end

    def turn_off(count: active_pids.count, wait: 30)
      count = [count.to_i, 0].max
      # grab a subset of active pids to turn off.
      pids = active_pids.sample(count)
      logger.info "Turning off #{pids.count} of #{active_pids.count} Sidekiq processes..."
      stop_processes(pids: pids)

      # Wait for processes to actually stop. NOTE: sending the TERM signal will
      # cause the process to wait for workers to finish. The amount of time it
      # will wait is set by the `timeout` configuration option when the process
      # is started. This can be changed in a config file (e.g.
      # config/sidekiq.yml) or by passing the -t option during startup. After
      # waiting, if the workers for the process still have not finished, the
      # process will be forcefully stopped with kill -9.
      # Here we wait up to 5 min for the processes to turn off.
      remaining = nil
      try_until(wait) do
        remaining = active_pids & pids
        remaining.empty?
      end

      if !remaining.empty?
        logger.warn "Waited #{wait} seconds to stop #{pids.count} Sidekiq " \
                    "process(es), but #{remaining.count} of those are still " \
                    "running. Processes may finish shutting down shortly, or " \
                    "there may have been an error during shutdown. See " \
                    "#{sidekiq_log_file} for more details."
      else
        logger.info "#{pids.count} Sidekiq processes turned off."
      end
    end

    def ensure_on(count: 1)
      count = [count.to_i, 0].max
      logger.info "Ensuring #{count} Sidekiq process(es) running; found #{active_pids.count}."
      if active_pids.count < count
        turn_on(count: count - active_pids.count)
      elsif active_pids.count > count
        turn_off(count: active_pids.count - count)
      end
    end

    def active_pids
      # NOTE: This command has been tested on OSX and Amazon linux.
      `ps aux | egrep 'sidekiq.*\[[0-9]+ of [0-9]+ busy\]' | awk '{print $2}'`.split(/\s/)
    end

    def logger=(logger)
      raise ArgumentError, "Logger object expected but #{logger.class} was given" unless logger.is_a? Logger
      @logger = logger
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    private

      # Starts `count` sidekiq processes in the background.
      def start_sidekiq_processes(count: 1)
        Dir.chdir project_dir do
          count.times { run_command start_sidekiq_cmd, spawn_new_process: true }
        end
      end

      # Stops sidekiq processes for the given pids, i.e. sends TERM signal.
      def stop_processes(pids: [])
        pids = active_pids & pids
        pids.each { |pid| run_command stop_sidekiq_cmd(pid) }
      end

      # Quiets sidekiq processes for the given pids, i.e. sends -TSTP signal.
      def quiet_processes(pids: [])
        pids = active_pids & pids
        pids.each { |pid| run_command quiet_sidekiq_cmd(pid) }
      end

      # Runs a block repeatedly for the given number of seconds, sleeping in
      # between calls for the given interval, and returns when the given number
      # of seconds has transpired, or when the block returns a truthy value,
      # whichever comes first.
      # @param seconds [Integer] The number of seconds to try the block until.
      # @param interval [Integer] The number of additonal seconds to sleep
      #   before trying the block again.
      # @param wait_msg [String] optional text to output when waiting to run
      #   the block again.
      # @return value of the block
      def try_until(seconds, interval: 5, wait_msg: "Waiting...")
        block_val = yield
        return if block_val
        stop_time = Time.now.to_i + [seconds.to_i, 0].max
        while !block_val && stop_time > Time.now.to_i
          logger.info wait_msg if wait_msg
          sleep interval if interval.to_i > 0
          block_val = yield
        end
        block_val
      end

      def worker_pids
        Sidekiq::Workers.new.map { |pid, thread_id, work| pid.split(':')[1] }
      end

      # Log the command, then run it. If spawn_new_process is TRUE, then call
      # it with `spawn`, otherwise with backticks.
      def run_command(command, spawn_new_process: false)
        logger.info "Running: #{command}"
        spawn_new_process ? spawn(command) : `#{command}`
      end

      def start_sidekiq_cmd
        "bundle exec sidekiq -e #{env} > #{sidekiq_log_file} 2>&1"
      end

      def sidekiq_log_file
        "log/sidekiq.log"
      end

      def stop_sidekiq_cmd(pid)
        "kill #{pid}"
      end

      def quiet_sidekiq_cmd(pid)
        "kill -TSTP #{pid}"
      end

      def default_config_file
        File.expand_path('../../../config/sidekiq.yml', __FILE__)
      end

      def project_dir
        File.expand_path('../../../', __FILE__)
      end

      def env
        ENV['RAILS_ENV'] || 'development'
      end
  end
end

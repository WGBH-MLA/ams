module AMS
  class ToggleSidekiq

    def initialize(logger)
      @logger = logger if logger
    end

    def is_running?
      # grep -v outputs non-matching lines (get rid of grep line)
      resp = `ps aux | grep sidekiq | grep -v grep`
      resp.length > 0
    end

    def def turn_on
      resp = `cd /var/www/ams/ && bundle exec sidekiq -e production > log/sidekiq.log 2>&1 &`
      @logger.info "Brought sidekiq to life, got resp #{resp}"
    end

    def def turn_off
      # get ps, grep for sidekiq (without returning grep), then awk dat
      resp = `kill -9 $(ps aux | grep '[s]idekiq' | awk '{print $2}')`
      @logger.info "Killed sidekiq, got resp #{resp}"
    end

    private

      def logger=(logger)
        raise ArgumentError, "Logger object expected but #{logger.class} was given" unless logger.is_a? Logger
        @logger = logger
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
  end
end

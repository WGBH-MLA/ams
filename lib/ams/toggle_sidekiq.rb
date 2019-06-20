require 'sidekiq/api'
redis_conn = { url: "redis://#{ENV['REDIS_SERVER']}:6379/", network_timeout: 5 }
Sidekiq.configure_server do |s|
  s.redis = redis_conn
end
Sidekiq.configure_client do |s|
  s.redis = redis_conn
end

Sidekiq::Logging.logger.level = Logger::DEBUG

module AMS
  class ToggleSidekiq

    def initialize(logger)
      self.logger = logger if logger
    end

    def is_running?
      # grep -v outputs non-matching lines (get rid of grep line)
      resp = `ps aux | grep sidekiq | grep -v grep`
      resp.length > 0
    end

    def turn_on

      3.times do |n|
        pid = fork do
          logger.info "Bringing sidekiq #{n} to life!"
          `cd /var/www/ams/ && bundle exec sidekiq -e production 1>&2 > log/sidekiq.log`
          Process.daemon
        end
        logger.info "Received daemon pid #{pid} for sidekiq #{n} launch"
      end
    end

    def turn_off
      # send signal to quiet processors
      resp = `kill -TSTP $(ps aux | grep '[s]idekiq' | awk '{print $2}')`
      logger.info "Set kill sequences to sidekiqs, resp #{resp}"

      workers = Sidekiq::Workers.new
      logger.info %(#{workers.count} Workers Working... Lets go to work)
      while workers.count > 0
        logger.info "Ingest Queue had #{workers.count} workers working... sleeping..."
        sleep 10 
      end

      # get ps, grep for sidekiq (without returning grep), then awk dat
      resp = `kill $(ps aux | grep '[s]idekiq' | awk '{print $2}')`
      logger.info "Killed sidekiq, hoo-ray!"
    end

    # private
      def logger=(logger)
        raise ArgumentError, "Logger object expected but #{logger.class} was given" unless logger.is_a? Logger
        @logger = logger
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
  end
end

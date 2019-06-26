require 'rubygems'
require 'bundler/setup'
require 'logger'
require_relative './postgres_vacuum_service'
require_relative './toggle_sidekiq'

# on ze box
# must do
# sudo yum install postgresql-devel
# gem install pg -v '0.18.4' --source 'https://rubygems.org/'

# crontab -e
# 0 * * * *  /bin/bash -l -c 'cd /var/www/ams && bundle exec ruby /var/www/ams/lib/ams/vacuum_full_fedora_db.rb'

#put PG database env variables in /etc/profile

module AMS
  class VacuumFullFedoraDB
    attr_reader :vacuum_service, :sidekiq_toggler

    def initialize(logger: nil)
      self.logger = logger if logger
      @vacuum_service = AMS::PostgresVacuumService.new(logger: self.logger)
      @sidekiq_toggler = AMS::ToggleSidekiq.new(logger: self.logger)
    end

    def run
      if vacuum_service.current_vacuum_full
        logger.info "VACUUM FULL already running, doing nothing."
        return
      else
        logger.info "Initiating VACUUM FULL for Fedora's Postgres DB..."
        sidekiq_toggler.turn_off if sidekiq_toggler.is_running?
        vacuum_service.run_vacuum_full
        # sleep to give vacc time to start for while loop signal
        sleep 10

        while vacuum_service.current_vacuum_full
          logger.info "Waiting for VACUUM FULL to complete..."
          sleep 30
        end
        sidekiq_toggler.turn_on
        logger.info "Finished VACUUM FULL of Fedora's Postgres DB."
      end
    end

    protected

      def logger=(logger)
        raise ArgumentError, "Logger object expected but #{logger.class} was given" unless logger.is_a? Logger
        @logger = logger
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
  end
end

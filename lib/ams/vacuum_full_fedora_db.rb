require 'rubygems'
require 'bundler/setup'
require 'logger'

require_relative './postgres_vacuum_service'
require_relative './toggle_sidekiq'

# on ze box
# must do
# sudo yum install postgresql-devel
# gem install pg -v '0.18.4' --source 'https://rubygems.org/'




# TODO: COMPLETELY UNTESTED!!!! TEST, MODIFY, AND REMOVE THIS COMMENT!!

# The idea here is to use this object in a cron job.
# It could be as simply as...
#
#   AMS::VacuumFullFedoraDB.run
#
# ... and run that every hour or so. The sweet spot would be to

module AMS
  class VacuumFullFedoraDB
    attr_reader :vacuum_service, :sidekiq_toggler

    def initialize(logger: nil)
      self.logger = logger if logger
      @vacuum_service = AMS::PostgresVacuumService.new(logger: self.logger)
      @sidekiq_toggler = AMS::ToggleSidekiq.new(self.logger)
    end

    def run
      unless vacuum_service.current_vacuum_full
        logger.info "FULL VAC not running"
        sidekiq_toggler.turn_off if sidekiq_toggler.is_running?
        logger.info "sidekiq turned off #{!sidekiq_toggler.is_running?}"
        vacuum_service.run_vacuum_full
        logger.info "running that big bad vacuum"
        # sleep to give vacc time to start for while loop signal
        sleep 10

        while vacuum_service.current_vacuum_full
          logger.info "sleeping..."
          sleep 5
        end
        sidekiq_toggler.turn_on
        logger.info "sidekiq turned on #{sidekiq_toggler.is_running?}"
      end
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

AMS::VacuumFullFedoraDB.new.run

require 'ams/postgres_vacuum_service'
require 'ams/toggle_sidekiq'


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
      @sidekiq_toggler = AMS::ToggleSidekiq.new(logger: self.logger)
    end

    def run
      unless vacuum_service.current_vacuum_full
        sidekiq_toggler.turn_off if sidekiq_toggler.is_running?
        # TODO: do we need to wait for processes to be killed?
        vacuum_service.run_vacuum_full
        while vacuum_service.current_vacuum_full
          sleep 5
        end
        sidekiq_toggler.turn_on
      end
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

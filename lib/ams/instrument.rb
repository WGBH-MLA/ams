require 'logger'

module AMS
  class << self

    def i_log
      @logger ||= Logger.new("log/instrument.log").tap do |logger|
        logger.level = Logger::INFO
        logger.formatter = proc { |_s, _d, _p, msg| "#{msg}\n" }
      end
    end

    def i_threshold
      0.1
    end

    def i(name, data={})
      raise 'block required' unless block_given?
      ActiveSupport::Notifications.unsubscribe(name)

      ActiveSupport::Notifications.subscribe(name) do |name, started, finished, unique_id, data|
        elapsed = (finished - started)
        if elapsed >= i_threshold
          # output a list of fields
          fields = [
            # elapsed time as float with 9 decimal points (no scientific notation).
            "%.4f" % elapsed,
            # name of the instrument
            name
          ]
          fields << data.inspect unless data.empty?
          msg = fields.join(',')
          i_log.info msg
          Rails.logger.error msg
        end
      end

      ActiveSupport::Notifications.instrument(name, data) do
        yield
      end
    end

    # No-op so we can easily turn stuff off just by changing #instrument to
    # #xinstrument
    def xi(*args)
      raise 'block required' unless block_given?
      yield
    end
  end
end

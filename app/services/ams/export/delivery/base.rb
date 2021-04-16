module AMS
  module Export
    module Delivery
      class Base
        attr_reader :export_results

        def initialize(export_results:)
          @export_results = export_results
        end

        def deliver
          raise "#{self.class}#deliver must be impelemented to deliver " \
                "export results to destination."
        end

        # Returns a Hash of data for use in follow-up notifications.
        # @return [Hash]
        def notification_data
          @notification_data ||= {}
        end
      end
    end
  end
end

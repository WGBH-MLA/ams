module AMS
  module Cleaner
    class Pipeline

      attr_reader :steps

      def initialize(steps = {})
        @steps = steps
      end

      def process(pbcore)
        steps.reduce(pbcore) do |pbc, step|
          step.process(pbc)
        end
        pbcore
      end

    end
  end
end

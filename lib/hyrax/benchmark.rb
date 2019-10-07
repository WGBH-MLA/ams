require 'benchmark'

module Hyrax
  class Benchmark
    attr_reader :results

    def initialize(&block)
      reset
    end

    def reset
      @procedure = nil
      @measurement_procedures = {}
      @results = []
    end

    def procedure(&block)
      raise ArgumentError, 'block required' unless block_given?
      @procedure = block
    end

    def measure(label, &block)
      raise ArgumentError, 'block required' unless block_given?
      add_measurement_procedure(label, block)
    end

    def run(trials: 1)
      raise 'No procedure specified. Specify a procedure by passing a block to #procedure' unless @procedure
      trials.to_i.times do |n|
        result = Result.new
        result.realtime = ::Benchmark.realtime { @procedure.call }
        result.measurements = take_measurements
        @results << result
      end
    end

    private

      def add_measurement_procedure(name, callable_procedure)
        @measurement_procedures[name] = callable_procedure
      end

      def take_measurements
        @measurement_procedures.map do |name, measurement_procedure|
          [name, measurement_procedure.call]
        end.to_h
      end

    class Result
      attr_accessor :realtime, :measurements

      def initialize
        @realtime = 0.0
        @measurements = {}
      end
    end
  end
end

require 'benchmark'

module Hyrax
  class Benchmark
    attr_reader :results, :output_file, :measurement_procedures

    def initialize(output_file: nil)
      @procedure = nil
      @measurement_procedures = {}
      @results = []
      @output_file = output_file
    end

    def procedure(&block)
      raise ArgumentError, 'block required' unless block_given?
      @procedure = block
    end

    def measure(label, &block)
      raise ArgumentError, 'block required' unless block_given?
      @measurement_procedures[label] = block
    end

    def run(trials: 1)
      raise 'No procedure specified. Specify a procedure by passing a block to #procedure' unless @procedure
      initialize_results
      write csv_header
      write csv_row 0
      trials.to_i.times do |trial|
        time = ::Benchmark.realtime { @procedure.call }
        record_result time: time
        write csv_row (trial + 1)
      end
    end

    private

      # Maps the @measurement_procedures hash to a hash where the values are the
      # results of running the measurement procedures.
      def take_measurements
        measurement_procedures.map do |name, measurement_procedure|
          [name, measurement_procedure.call]
        end.to_h
      end

      # Cleare existing results and take a first round of measurements at time
      # 0.0
      def initialize_results
        @results = []
        record_result(time: 0.0)
      end

      # Adds a result to the results array with the given time, takes
      # measurements, and calculates the accumulated time.
      def record_result(time:)
        @results << Result.new(
          time: time,
          accum_time: time + ( @results.last&.accum_time || 0.0 ),
          measurements: take_measurements
        )
      end

      def csv_header
        headers = ['Trial', 'Time', 'Accumulated Time'] + measurement_procedures.keys
        "\"#{headers.join('","')}\""
      end

      def csv_row(trial)
        result = @results[trial]
        ( [trial, result.time, result.accum_time] + result.measurements.values ).join(',')
      end

      def write(str)
        if output_file
          File.open(output_file, 'a') { |f| f.puts str }
        else
          STDOUT.puts str
          STDOUT.flush
        end
      end

    # Simple class for capturing result data.
    class Result
      attr_accessor :time, :accum_time, :measurements

      def initialize(time:, accum_time:, measurements:)
        # Because a lot relies on the results being accurate, do some error
        # checking up front on the data to ensure it's in bounds.
        raise ArgumentError, ':time must be a float' unless time.is_a? Float
        raise ArgumentError, ':accum_time must be a float' unless accum_time.is_a? Float
        raise ArgumentError, ':accum_time must be greater than or equal to :time' unless accum_time >= time
        raise ArgumentError, ':time must be greater than 0.0' unless time >= 0.0
        raise ArgumentError, ':accum_time must be greater than or equal to 0.0' unless accum_time >= 0.0
        raise ArgumentError, ':measurements must be a Hash' unless measurements.is_a? Hash
        @time = time
        @accum_time = accum_time
        @measurements = measurements
      end
    end
  end
end

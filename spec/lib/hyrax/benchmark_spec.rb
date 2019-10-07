require 'hyrax/benchmark'
require 'tempfile'

RSpec.describe Hyrax::Benchmark do
  let(:iterations) { rand(3..7) }
  let(:benchmark) { described_class.new }
  let(:foo) { double }

  before do
    # Set the benchmark procedure to be some arbitrary thing that we can verify
    # has happened in specs.
    allow(foo).to receive(:bar)
    benchmark.procedure { foo.bar }

    # Simulate something that takes a second to measure.
    benchmark.measure(:some_measurement) do
      sleep 1
      rand
    end
  end


  describe '#run' do
    context 'with no arguments' do
      before { benchmark.run }
      it 'runs the benchmark once' do
        expect(foo).to have_received(:bar).exactly(1).times
      end
    end

    context 'with {trials: N}' do
      let(:trials) { rand(1..10) }
      before { benchmark.run trials: trials }
      it 'runs the benchmark N times' do
        expect(foo).to have_received(:bar).exactly(trials).times
      end

      it 'records N + 1 measurements' do
        expect(benchmark.results.count).to eq trials + 1
      end

      it 'records accumulated time correctly' do
        calculated_accum_time = benchmark.results.map(&:time).reduce(:+)
        expect(benchmark.results.last.accum_time).to eq calculated_accum_time
      end

      it 'ensures accumulated time is always increasing' do
        prev_result = nil
        benchmark.results.each do |result|
          if prev_result.nil?
            prev_result = result
          else
            expect(prev_result.accum_time).to be < result.accum_time
          end
        end
      end
    end
  end
end

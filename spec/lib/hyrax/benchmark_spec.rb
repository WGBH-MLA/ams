require 'hyrax/benchmark'

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
  end
end

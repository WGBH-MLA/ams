require 'rails_helper'
require 'pbcore/factories'

RSpec.describe Hyrax::Actors::DigitalInstantiationActor do

  let(:user) { create(:user) }
  let(:current_ability) { Ability.new(user) }

  # NOTE: Actor contructors require 1 parameter: the next actor in the stack.
  #   Passing the Terminator effectively creates an actor stack of only the
  #   actor we're testing.
  subject { described_class.new(Hyrax::Actors::Terminator.new) }

  describe '#create' do
    let(:pbcore_xml) do
      build(:pbcore_instantiation,
        physical: nil,
        digital: build(:pbcore_instantiation_digital)
      ).to_xml
    end

    let(:digital_instantiation) do
      DigitalInstantiation.new.tap do |di|
        di.skip_file_upload_validation = true
      end
    end

    # Attributes used to build the record. Override in contexts below.
    let(:attrs) { { pbcore_xml: pbcore_xml } }
    let(:env) { Hyrax::Actors::Environment.new(digital_instantiation, current_ability, attrs) }

    # Call the method under test before specs, test side effects.
    before { subject.create(env) }

    context 'with valid input data' do
      # Minimal valid input data
      let(:attrs) { { pbcore_xml: pbcore_xml } }

      before { expect(digital_instantiation).to be_valid }

      it 'creates a DigitalInstantiation' do
        expect(digital_instantiation).to be_persisted
      end
    end
  end
end

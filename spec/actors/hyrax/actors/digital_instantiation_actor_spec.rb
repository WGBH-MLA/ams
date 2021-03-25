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

    let(:attrs) { { pbcore_xml: pbcore_xml } }

    let(:digital_instantiation) { DigitalInstantiation.new }

    let(:env) { Hyrax::Actors::Environment.new(digital_instantiation, current_ability, attrs) }

    before { subject.create(env) }

    it 'creates a DigitalInstantiation' do
      expect(digital_instantiation).to be_persisted
    end
  end
end

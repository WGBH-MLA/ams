require 'rails_helper'

RSpec.describe Hyrax::Actors::PhysicalInstantiationActor do

  let(:user) { create(:user) }
  let(:current_ability) { Ability.new(user) }

  # NOTE: Actor contructors require 1 parameter: the next actor in the stack.
  #   Passing the Terminator effectively creates an actor stack of only the
  #   actor we're testing.
  subject { described_class.new(Hyrax::Actors::Terminator.new) }

  describe '#create' do
    let(:physical_instantiation) { PhysicalInstantiation.new }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(physical_instantiation, current_ability, attrs) }

    before { subject.create(env) }

    it 'creates a PhysicalInstantiation' do
      expect(physical_instantiation).to be_persisted
    end
  end
end

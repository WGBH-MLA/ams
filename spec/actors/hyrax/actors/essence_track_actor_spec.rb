require 'rails_helper'

RSpec.describe Hyrax::Actors::EssenceTrackActor do

  let(:user) { create(:user) }
  let(:current_ability) { Ability.new(user) }

  # NOTE: Actor contructors require 1 parameter: the next actor in the stack.
  #   Passing the Terminator effectively creates an actor stack of only the
  #   actor we're testing.
  subject { described_class.new(Hyrax::Actors::Terminator.new) }

  describe '#create' do
    let(:essence_track) { build(:essence_track) }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(essence_track, current_ability, attrs) }

    before { subject.create(env) }

    it 'creates an EssenceTrack' do
      expect(essence_track).to be_persisted
    end
  end
end

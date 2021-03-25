require 'rails_helper'
require 'pbcore/factories'

RSpec.describe Hyrax::Actors::EssenceTrackActor do

  let(:user) { create(:user) }
  let(:current_ability) { Ability.new(user) }

  # NOTE: Actor contructors require 1 parameter: the next actor in the stack.
  #   Passing the Terminator effectively creates an actor stack of only the
  #   actor we're testing.
  subject { described_class.new(Hyrax::Actors::Terminator.new) }

  describe '#create' do
    let(:essence_track) { EssenceTrack.new }

    # Attributes used to build the record. Override in contexts below.
    let(:attrs) { { } }
    let(:env) { Hyrax::Actors::Environment.new(essence_track, current_ability, attrs) }

    # Call the method under test before specs, test side effects.
    before { subject.create(env) }

    context 'with valid input data' do
      # Minimal valid input data
      let(:attrs) do
        { track_type: "blerg",
          track_id: [ 123 ] }
      end

      before { expect(essence_track).to be_valid }

      it 'creates a EssenceTrack' do
        expect(essence_track).to be_persisted
      end
    end
  end
end

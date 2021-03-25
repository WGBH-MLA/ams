# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe Hyrax::Actors::AssetActor do

  let(:user) { create(:user) }
  let(:current_ability) { Ability.new(user) }

  # NOTE: ActorActor contructor takes 1 param, the next actor in the stack.
  #   Passing the Terminator effectively creates an actor stack of only the
  #   actor we're testing.
  subject { described_class.new(Hyrax::Actors::Terminator.new) }

  describe '#create' do
    let(:asset) { build(:asset) }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(asset, current_ability, attrs) }

    before { subject.create(env) }

    it 'creates an Asset' do
      expect(asset).to be_persisted
    end
  end
end

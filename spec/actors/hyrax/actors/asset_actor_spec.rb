# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe Hyrax::Actors::AssetActor do
  let(:asset) { build(:asset, :with_physical_digital_and_essence_track, user: admin, intended_children_count: intended_children_count) }
  let(:env) { Hyrax::Actors::Environment.new(asset, Ability.new(admin), attrs) }
  let(:admin) { create(:admin_user) }
  let(:attrs) { {} }
  let(:intended_children_count) { 3 }
  let(:terminator) { Hyrax::Actors::Terminator.new }

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  shared_examples 'setting validation status' do |method|
    context 'when the asset has all of its intended children' do
      let(:intended_children_count) { 3 }

      it 'sets the status to "valid"' do
        expect(asset.validation_status_for_aapb).to be_empty

        middleware.public_send(method, env)

        expect(asset.validation_status_for_aapb).to eq(['valid'])
      end
    end

    context 'when the asset is missing children' do
      let(:intended_children_count) { 5 }

      it 'sets the status to "missing child record(s)"' do
        expect(asset.validation_status_for_aapb).to be_empty

        middleware.public_send(method,env)

        expect(asset.validation_status_for_aapb).to eq(['missing child record(s)'])
      end
    end
  end

  describe '#create' do
    it 'calls #set_validation_status' do
      expect(middleware).to receive(:set_validation_status).once

      middleware.create(env)
    end

    include_examples 'setting validation status', :create
  end

  describe '#update' do
    it 'calls #set_validation_status' do
      expect(middleware).to receive(:set_validation_status).once

      middleware.update(env)
    end

    include_examples 'setting validation status', :update
  end
end

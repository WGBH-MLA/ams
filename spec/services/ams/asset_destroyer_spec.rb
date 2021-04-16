require 'rails_helper'
require 'ams/asset_destroyer'

RSpec.describe AMS::AssetDestroyer do

  describe 'destroy' do
    context 'when given a list of IDs for Assets with no children' do
      let(:asset_ids) { create_list(:asset, 3).map(&:id) }

      it 'deletes the Assets' do
        expect(asset_ids).to all( exist_in_repository )
        subject.destroy asset_ids
        expect(asset_ids).to all( not_exist_in_repository )
        # Check that Tombstones have been removed too
        asset_ids.each do |id|
          # Return the desired error instead of Ldp::Gone which implies a tombstone
          expect{ ActiveFedora::Base.find id }.to raise_error(ActiveFedora::ObjectNotFoundError)
        end
      end
    end

    context 'and when the Assets have child objects' do
      before do
        # Here we create 2 "families" of records (i.e. Asset with Digital
        # Instantiations, Physical Instantiations, and Contributions, and
        # Instantitions have Essence Tracks). We collect the IDs in an
        # instance variable that we can then use for the test.
        @all_ids = @asset_ids = []
        assets = FactoryBot.create_list(:asset, 2).each do |asset|
          @all_ids << asset.id
          FactoryBot.create_list(:digital_instantiation, 2).each do |digital_instantiation|
            @all_ids << digital_instantiation.id
            asset.ordered_members += [ digital_instantiation ]
            FactoryBot.create_list(:essence_track, 2).each do |essence_track|
              digital_instantiation.ordered_members += [ essence_track ]
            end
          end

          FactoryBot.create_list(:physical_instantiation, 2).each do |physical_instantiation|
            @all_ids << physical_instantiation.id
            asset.ordered_members += [ physical_instantiation ]
            FactoryBot.create_list(:essence_track, 2).each do |essence_track|
              @all_ids << essence_track.id
              physical_instantiation.ordered_members += [ essence_track ]
            end
          end

          FactoryBot.create_list(:contribution, 2).each do |contribution|
            @all_ids << contribution.id
            asset.ordered_members += [ contribution ]
          end
        end
        @asset_ids = assets.map(&:id)
      end

      it 'deletes the Assets and all child objects' do
        expect(@all_ids).to all( exist_in_repository )
        subject.destroy @asset_ids
        expect(@all_ids).to all( not_exist_in_repository )
      end
    end
  end

  describe 'eradicate_asset_tombstones' do
    context 'when given a list of IDs' do
      let(:asset) { create(:asset) }
      # let(:destroy_asset) { Hyrax::CurationConcern.actor.destroy(Hyrax::Actors::Environment.new(asset, ability, {})) }

      it 'skips destroying the tombstone if an Asset exists' do
        subject.eradicate_asset_tombstones [ asset.id ]
        expect((ActiveFedora::Base.find asset.id)).to eq(asset)
      end

      it 'deletes the tombstone if no Asset exists' do
        asset.destroy
        expect{ ActiveFedora::Base.find asset.id }.to raise_error(Ldp::Gone)
        subject.eradicate_asset_tombstones [ asset.id ]
        expect{ ActiveFedora::Base.find asset.id }.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end
end

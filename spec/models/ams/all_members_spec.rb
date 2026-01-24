require 'rails_helper'

RSpec.describe AMS::AllMembers, reset_data: false  do
  before(:all) do
    # Creating an @asset family is slow, so let's not do it for every example
    # using a `let'; use instance var instead.
    @asset = create(:asset_resource, :family)
  end

  context "an @asset with nested members" do
    describe "#all_members" do
      it 'returns a list of all members' do
        # Re-fetch the asset from Valkyrie to get fresh data without memoization
        fresh_asset = Hyrax.query_service.find_by(id: @asset.id)
        # Fetch solr doc fresh to avoid stale data from reset_data: false
        asset_solr_doc = SolrDocument.find(@asset.id)

        actual_members_set = fresh_asset.all_members.map(&:id).map(&:to_s).to_set
        expected_member_set = asset_solr_doc.all_members.map(&:id).map(&:to_s).to_set
        expect(actual_members_set).to eq expected_member_set
      end


      context 'with the :only param passed' do
        it 'only returns classes specified by :only param' do
          # Re-fetch the asset from Valkyrie to get fresh data without memoization
          fresh_asset = Hyrax.query_service.find_by(id: @asset.id)
          expect(fresh_asset.all_members(only: DigitalInstantiationResource).to_set).to all( be_a DigitalInstantiationResource )
        end
      end
    end
  end
end

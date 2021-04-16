require 'rails_helper'

RSpec.describe AMS::AllMembers, reset_data: false  do
  before(:all) do
    # Creating an @asset family is slow, so let's not do it for every example
    # using a `let'; use instance var instead.
    @asset = create(:asset, :family)

    # Use the complimentary recursive method SolrDocument#all_members to check
    # the values.
    @asset_solr_doc = SolrDocument.find(@asset.id)
  end

  context "an @asset with nested members" do
    describe "#all_members" do
      it 'returns a list of all members' do
        actual_members_set = @asset.all_members.map(&:id).to_set
        expected_member_set = @asset_solr_doc.all_members.map(&:id).to_set
        expect(actual_members_set).to eq expected_member_set
      end


      context 'with the :only param passed' do
        it 'only returns classes specified by :only param' do
          expect(@asset.all_members(only: DigitalInstantiation).to_set).to all( be_a DigitalInstantiation )
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.feature 'PBCore XML endpoints' do

  before { login_as(create(:user)) }

  context 'for an AssetResource record' do
    let(:asset_resource) { create(:asset_resource) }
    let(:expected_pbcore_xml) { SolrDocument.new(asset_resource.to_solr).export_as_pbcore }

    describe '/concerns/asset_resources/[id].xml' do
      before do
        visit "#{url_for(asset_resource)}.xml"
      end

      it 'returns the PBCore XML' do
        expect(page.html).to eq expected_pbcore_xml
      end
    end
  end
end

require 'rails_helper'

RSpec.feature 'PBCore XML endpoints' do

  before { login_as(create(:user)) }

  context 'for an Asset record' do
    let(:asset) { create(:asset) }
    let(:expected_pbcore_xml) { SolrDocument.new(asset.to_solr).export_as_pbcore }

    describe '/concerns/assets/[id].xml' do
      before do
        visit "#{url_for(asset)}.xml"
      end

      it 'returns the PBCore XML' do
        expect(page.html).to eq expected_pbcore_xml
      end
    end
  end
end

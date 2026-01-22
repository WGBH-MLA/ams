require 'rails_helper'

RSpec.feature 'PBCore XML endpoints' do

  before do
    login_as(create(:user))
    # Stub breadcrumb method to avoid active_fedora_basis_path error
    allow_any_instance_of(Hyrax::AssetResourcesController).to receive(:add_breadcrumb_for_action)
  end

  context 'for an AssetResource record' do
    let(:asset_resource) { create(:asset_resource) }
    let(:expected_pbcore_xml) { SolrDocument.new(asset_resource.to_solr).export_as_pbcore }

    describe '/concerns/asset_resources/[id].xml' do
      before do
        visit "#{hyrax_asset_resource_path(asset_resource)}.xml"
      end

      it 'returns the PBCore XML' do
        expect(page.html).to eq expected_pbcore_xml
      end
    end
  end
end

require 'rails_helper'

RSpec.describe AMS::Export::Search::CatalogSearch do
  context 'when searching for AssetResource records' do
    # create asset_resources first with let!
    # Here we create a few more than what would normally show up in a paginated
    # result (default 10 per page), to guarantee that catalog's per_page limit
    # is not in effect.
    let!(:asset_resources) { create_list(:asset_resource, rand(11..14), title: [ searchable_title ] ) }
    let(:searchable_title) { Faker::Lorem.sentence }
    let(:search_params) { { q: searchable_title } }
    let(:solr_documents) { subject.solr_documents }
    let(:asset_resource_ids) { Set.new(asset_resources.map { |v| v.id.to_s }) }
    let(:solr_doc_ids) { Set.new(solr_documents.map(&:id)) }
    let(:user) { create(:user) }

    subject { described_class.new(search_params: search_params, user: user) }

    describe '#solr_documents' do
      it 'is expected to return solr documents for the found AssetResource records' do
        expect(solr_documents.count).to eq asset_resources.count
        expect(asset_resource_ids).to eq solr_doc_ids
      end
    end

    describe '#num_found' do
      it 'is expected to return number of AssetResources in the query' do
        expect(subject.num_found).to eq asset_resources.count
      end
    end
  end
end

require 'rails_helper'

RSpec.describe AMS::Export::Search::CatalogSearch do
  context 'when searching for Asset records' do
    skip "Make this work for Blacklight 7.0.0 which doesn't have Blacklight::SearchHelper" unless App.rails_5_1?
    # create assets first with let!
    # Here we create a few more than what would normally show up in a paginated
    # result (default 10 per page), to guarantee that catalog's per_page limit
    # is not in effect.
    let!(:assets) { create_list(:asset, rand(11..14), title: [ searchable_title ] ) }
    let(:searchable_title) { Faker::Lorem.sentence }
    let(:search_params) { { q: searchable_title } }
    let(:solr_documents) { subject.solr_documents }
    let(:asset_ids) { Set.new(assets.map(&:id)) }
    let(:solr_doc_ids) { Set.new(solr_documents.map(&:id)) }
    let(:user) { create(:user) }

    subject { described_class.new(search_params: search_params, user: user) }

    describe '#solr_documents' do
      it 'is expected to return solr documents for the found Asset records' do
        expect(solr_documents.count).to eq assets.count
        expect(asset_ids).to eq solr_doc_ids
      end
    end

    describe '#num_found' do
      it 'is expected to return number of Assets in the query' do
        expect(subject.num_found).to eq assets.count
      end
    end
  end
end

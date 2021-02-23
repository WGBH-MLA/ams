require 'rails_helper'

RSpec.describe AMS::Export::Search::AssetsSearch do
  describe '#solr_documents' do
    # create assets first with let!
    let!(:assets) { create_list(:asset, rand(11..14), title: [ searchable_title ] ) }
    let(:searchable_title) { Faker::Lorem.sentence }
    let(:search_params) { { q: searchable_title } }
    let(:solr_documents) { subject.solr_documents }
    let(:asset_ids) { Set.new(assets.map(&:id)) }
    let(:solr_doc_ids) { Set.new(solr_documents.map(&:id)) }
    let(:user) { create(:user) }

    subject { described_class.new(search_params: search_params, user: user) }

    it 'is expected to return solr documents for the found Asset records' do
      expect(solr_documents.count).to eq assets.count
      expect(asset_ids).to eq solr_doc_ids
    end
  end
end

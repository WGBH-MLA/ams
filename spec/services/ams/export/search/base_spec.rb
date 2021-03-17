require 'rails_helper'

RSpec.describe AMS::Export::Search::Base do
  let(:user) { create(:user) }
  let(:search_params) { { } } # override in contexts below
  subject { described_class.new(search_params: search_params, user: user) }

  describe '#solr_documents' do
    context 'when searching for Asset records' do
      # create assets first with let!
      let!(:assets) { create_list(:asset, rand(11..14), title: [ searchable_title ] ) }
      let(:searchable_title) { Faker::Lorem.sentence }
      let(:search_params) { { q: searchable_title } }
      let(:solr_documents) { subject.solr_documents }
      let(:asset_ids) { Set.new(assets.map(&:id)) }
      let(:solr_doc_ids) { Set.new(solr_documents.map(&:id)) }

      it 'is expected to return solr documents for the found Asset records' do
        expect(solr_documents.count).to eq assets.count
        expect(asset_ids).to eq solr_doc_ids
      end
    end
  end

  describe 'current_ability' do
    it 'returns an Ability class for the user' do
      expect(subject.current_ability).to be_a Ability
      expect(subject.current_ability.current_user).to eq user
    end
  end

  describe 'validation' do
    context 'when the number of search results exceeds the max' do
      let(:max) { described_class::MAX_LIMIT }
      let(:num_found) { max + 1 }
      before { allow(subject).to receive(:num_found).and_return(num_found) }
      it 'is invalid with an error message' do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include "Export of size #{num_found} is too large. Max export limit is #{max}."
      end
    end
  end
end

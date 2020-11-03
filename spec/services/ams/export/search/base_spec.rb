require 'rails_helper'

RSpec.describe AMS::Export::Search::Base do
  let(:user) { create(:user) }
  let(:search_params) { { } }
  subject { described_class.new(search_params: search_params, user: user) }

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

  describe 'current_ability' do
    it 'returns an Ability class for the user' do
      expect(subject.current_ability).to be_a Ability
      expect(subject.current_ability.current_user).to eq user
    end
  end

  context 'subclasses' do
    let(:subclass) do
      Class.new(described_class) do
        def response
          # The bare minimum of what this method is expected to return.
          { 'response' => { 'docs' => [ {id: 123}, {id: 234} ] } }
        end

        def response_without_rows
          # The bare minimum of what this method is expected to return.
          { 'response' => { 'numFound' => 500 } }
        end
      end.new(search_params: search_params, user: user)
    end

    describe '#solr_documents' do
      it "returns SolrDocument instances containing data from #response['response']['docs']" do
        solr_doc_ids = Set.new(subclass.solr_documents.map(&:id))
        expect(solr_doc_ids).to eq Set.new([123, 234])
      end
    end

    describe '#num_found' do
      it "is a shortcut to #response_without_rows['response']['numFound']" do
        expect(subclass.num_found).to eq 500
      end
    end
  end
end

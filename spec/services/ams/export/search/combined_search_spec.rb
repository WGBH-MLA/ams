require 'rails_helper'

RSpec.describe AMS::Export::Search::CombinedSearch do

  # Create some groups of random fake solr docs. The 'id' field only is
  # sufficient.
  let(:groups_of_fake_solr_docs) do
    rand(2..3).times.map do
      rand(5..10).times.map { { 'id' => SecureRandom.uuid } }
    end
  end

  # Create some fake Search objects based on the groups of fake solr docs.
  let(:fake_searches) do
    groups_of_fake_solr_docs.map do |fake_solr_doc_group|
      instance_double(AMS::Export::Search::Base, num_found: fake_solr_doc_group.count, solr_documents: fake_solr_doc_group )
    end
  end

  # All expected solr docs is a flattened array of each group of solr docs
  # returned by each search.
  let(:all_expected_solr_docs) { groups_of_fake_solr_docs.flatten }

  # Expected total num found is the count of all
  let(:expected_total_num_found) { all_expected_solr_docs.count }

  # create the subject under test with our fake searches.
  subject { described_class.new(searches: fake_searches) }

  describe '#num_found' do
    it 'aggregates the #num_found from its list of searches' do
      expect(subject.num_found).to eq expected_total_num_found
    end
  end

  describe 'solr_documents' do
    it 'aggregates the #solr_documents from its list of searches' do
      expect(subject.solr_documents).to eq all_expected_solr_docs
    end

    context 'when combining searches with duplicate results' do
      let(:fake_searches_with_duplicates) do
        fake_searches + fake_searches.sample(rand(1..3))
      end
      subject { described_class.new(searches: fake_searches_with_duplicates) }
      it 'does not return the duplicate results' do
        expect(subject.solr_documents).to eq all_expected_solr_docs
      end
    end
  end
end

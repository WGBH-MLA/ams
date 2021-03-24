require 'rails_helper'

RSpec.describe AMS::Export::Search::DigitalInstantiationsSearch do
  describe 'solr_documents' do
    # Create a random, but searchable title.
    let(:searchable_title) { Faker::Lorem.sentence }

    # Create 1..3 assets each with a searchable title and having both digital
    # and physical instantiations.
    let!(:assets) do
      rand(1..3).times.map do
        ordered_members = [
          create_list(:digital_instantiation, rand(1..2)),
          create_list(:physical_instantiation, rand(1..2))
        ].flatten
        create(:asset, title: [ searchable_title], ordered_members: ordered_members)
      end
    end

    # Grab all the DigitalInstantiation IDs that were created.
    let(:digital_instantiation_ids) do
      Set.new(assets.map(&:digital_instantiations).flatten.map(&:id))
    end

    # Create a user, required for searching.
    let(:user) { create(:user) }

    # Set the search params to search for the searchable_title
    let(:search_params) { { q: searchable_title } }

    # Create the object under test with the search params and the test user.
    let(:solr_documents) do
      described_class.new(search_params: search_params, user: user).solr_documents
    end

    let(:expected_solr_doc_ids) do
      assets.map(&:digital_instantiations).flatten.map(&:id)
    end

    # And finally, after all that setup, run the spec.
    it 'returns all of the DigitalInstantiation Solr documents that are ' \
       'members of the the Assets records returned by the search params' do
      # Grab all the SolrDocument IDs returned from the search.
      expect(solr_documents).not_to be_empty
      solr_doc_ids = solr_documents.map(&:id)
      # NOTE: The SolrDocument objects will differ due to 'score' property.
      # Comparing the set of created IDs with the set of found IDs should be
      # sufficient.
      expect(Set.new(solr_doc_ids)).to eq Set.new(expected_solr_doc_ids)
    end
  end
end

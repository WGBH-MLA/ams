require 'rails_helper'

RSpec.describe AMS::Export::Search::PhysicalInstantiationsSearch do
  describe 'solr_documents' do
    # Create a random, but searchable title.
    let(:searchable_title) { Faker::Lorem.sentence }

    # Create 1..3 asset_resources each with a searchable title and having both digital
    # and physical instantiation_resources.
    let!(:asset_resources) do
      rand(1..3).times.map do
        members = [
          create_list(:digital_instantiation_resource, rand(1..2)),
          create_list(:physical_instantiation_resource, rand(1..2))
        ].flatten
        create(:asset_resource, title: [ searchable_title], members: members)
      end
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
      asset_resources.map(&:physical_instantiations).flatten.map(&:id)
    end

    # And finally, after all that setup, run the spec.
    it 'returns all of the PhysicalInstantiation Solr documents that are ' \
       'members of the the Asset_Resources records returned by the search params' do
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

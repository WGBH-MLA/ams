# Generated via
#  `rails generate hyrax:work Contribution`
class Contribution < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::AMS::IdentifierService

  self.indexer = ContributionIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  property :bulkrax_identifier, predicate: ::RDF::URI("https://iro.bl.uk/resource#bulkraxIdentifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end
  
  property :contributor, predicate: ::RDF::URI.new("http://www.w3.org/2006/vcard/ns#hasName"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :contributor_role, predicate: ::RDF::URI.new("http://www.w3.org/2006/vcard/ns#hasRole"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :portrayal, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasCastRole"), multiple: false, index_to_parent:true do |index|
    index.as :stored_searchable
  end

  property :affiliation, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasAffiliation"), multiple: false, index_to_parent:true do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end

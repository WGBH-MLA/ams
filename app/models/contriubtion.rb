# Generated via
#  `rails generate hyrax:work Contriubtion`
class Contriubtion < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = ContriubtionIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Contriubtion'

  property :contributor_role, predicate: ::RDF::URI.new("http://www.w3.org/2006/vcard/ns#hasRole"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :portrayal, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasCastRole"), multiple: false do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end

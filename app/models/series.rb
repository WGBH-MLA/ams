# Generated via
#  `rails generate hyrax:work Series`
class Series < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = SeriesIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your series must have a title.' }
  validates :description, presence: { message: 'Your series must have a description.' }

  property :audience_level, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasTargetAudience"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :audience_rating, predicate: ::RDF::URI.new("https://www.ebu.ch/metadata/ontologies/ebucore/index.html#Type"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :annotation, predicate: ::RDF::URI.new("http://www.w3.org/2004/02/skos/core#note"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :rights_summary, predicate: ::RDF::URI.new("http://purl.org/dc/elements/1.1/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :rights_link, predicate: ::RDF::URI.new("http://www.europeana.eu/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end

# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
class DigitalInstantiation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = DigitalInstantiationIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a Title.' }
  validates :digital_format, presence: { message: 'Your work must have a Digital Format.' }
  validates :location, presence: { message: 'Your work must have a Location.' }
  validates :media_type, presence: { message: 'Your work must have a Media Type.' }
  self.human_readable_type = 'Digital Instantiation'

  property :date, predicate: ::RDF::URI.new("http://purl.org/dc/terms/date"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :dimensions, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#dimensions"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :digital_format, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasFormat"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :standard, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasStandard"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :location, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#locator"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :media_type, predicate: ::RDF::URI.new("http://purl.org/dc/terms/type"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :generations, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasGeneration"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :file_size, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#fileSize"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :time_start, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#start"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :duration, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#duration"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :data_rate, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#bitRate"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :colors, predicate: ::RDF::URI.new("http://id.loc.gov/ontologies/bibframe.html#c_ColorContent"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :rights_summary, predicate: ::RDF::URI.new("http://purl.org/dc/elements/1.1/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :rights_link, predicate: ::RDF::URI.new("http://www.europeana.eu/rights"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :annotation, predicate: ::RDF::URI.new("http://www.w3.org/2004/02/skos/core#note"), multiple: true do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata if you have any further properties define above in current model
  include ::Hyrax::BasicMetadata
end
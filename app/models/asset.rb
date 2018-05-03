# Generated via
#  `rails generate hyrax:work Asset`
class Asset < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = AssetIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your asset must have a title.' }
  validates :description, presence: { message: 'Your asset must have a description.' }

  self.human_readable_type = 'Asset'

  property :asset_types, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasType"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :genre, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasGenre"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :broadcast, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#dateBroadcast"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :created, predicate: ::RDF::URI.new("http://purl.org/dc/terms/created"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :copyright_date, predicate: ::RDF::URI.new("http://id.loc.gov/ontologies/bibframe.html#p_copyrightDate"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :date, predicate: ::RDF::URI.new("http://purl.org/dc/terms/date"), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :episode_number, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#episodeNumber"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :spatial_coverage, predicate: ::RDF::Vocab::DC.coverage, multiple: true do |index|
    index.as :stored_searchable
  end

  property :temporal_coverage, predicate: ::RDF::URI.new("http://id.loc.gov/ontologies/bibframe.html#p_temporalCoverage"), multiple: true do |index|
    index.as :stored_searchable
  end

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

  property :local_identifier, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/identifiers/local"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :pbs_nola_code, predicate: ::RDF::URI.new("http://id.loc.gov/ontologies/bibframe.html#p_code"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :eidr_id, predicate: ::RDF::URI.new("https://www.w3.org/2002/07/owl#sameAs"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :topics, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasKeyword"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :subject, predicate: ::RDF::URI.new("http://purl.org/dc/elements/1.1/subject"), multiple: true do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata if you have any further properties define above in current model
  include ::Hyrax::BasicMetadata
end

# Generated via
#  `rails generate hyrax:work EssenceTrack`
class EssenceTrack < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EssenceTrackIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :track_type, presence: { message: 'Your work must have track type.' }
  validates :track_id, presence: { message: 'Your work must have track ID.' }

  property :track_type, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#trackType"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :track_id, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#trackName"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :standard, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasStandard"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :encoding, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasEncodingFormat"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :data_rate, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#bitRate"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :frame_rate, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#frameRate"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :playback_inch_per_sec, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#inchesPerSecond"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :playback_frame_per_sec, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#framesPerSecond"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :sample_rate, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#sampleRate"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :bit_depth, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#bitDepth"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :frame_width, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#frameWidth"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :frame_height, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#frameHeight"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :aspect_ratio, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#aspectRatio"), multiple: true do |index|
    index.as :stored_searchable
  end

  property :time_start, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#start"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :duration, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#duration"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :annotation, predicate: ::RDF::URI.new("http://www.w3.org/2004/02/skos/core#note"), multiple: true do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata if you have any further properties define above in current model
  include ::Hyrax::BasicMetadata
end
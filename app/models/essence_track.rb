# Generated via
#  `rails generate hyrax:work EssenceTrack`
class EssenceTrack < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::AMS::IdentifierService

  self.indexer = EssenceTrackIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :track_type, presence: true

  validates_each :duration, :time_start, allow_blank: true do |record, attr, value|
    if value !~ AMS::TimeCodeService.regex
      record.errors.add(:base, "Invalid format for #{attr.to_s.humanize}. Use HH:MM:SS, H:MM:SS, MM:SS, M:SS, or HH:MM:SS")
      record.errors.add(attr, "Invalid format for #{attr.to_s.humanize}. Use HH:MM:SS, H:MM:SS, MM:SS, M:SS, or HH:MM:SS")
    end
  end

  property :bulkrax_identifier, predicate: ::RDF::URI("http://ams2.wgbh-mla.org/resource#bulkraxIdentifier"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

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

  property :playback_speed, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#playbackSpeed"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :playback_speed_units, predicate: ::RDF::URI.new('http://pbcore.org#hasPlaybackSpeedUnits'), multiple: false do |index|
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

  property :aspect_ratio, predicate: ::RDF::URI.new("http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#aspectRatio"), multiple: false do |index|
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

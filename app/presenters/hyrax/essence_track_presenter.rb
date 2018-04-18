# Generated via
#  `rails generate hyrax:work EssenceTrack`
module Hyrax
  class EssenceTrackPresenter < Hyrax::WorkShowPresenter
    delegate :track_type, :track_id, :standard, :encoding, :data_rate, :frame_rate,:playback_inch_per_sec, :playback_frame_per_sec,
             :sample_rate, :bit_depth, :frame_width, :frame_height, :time_start, :duration, :annotation, to: :solr_document
  end
end
# Generated via
#  `rails generate hyrax:work EssenceTrack`
module Hyrax
  class EssenceTrackPresenter < Hyrax::WorkShowPresenter
    delegate :track_type, :track_id, :standard, :encoding, :data_rate, :frame_rate,:playback_speed, :playback_speed_units,
             :sample_rate, :bit_depth, :frame_width, :frame_height, :time_start, :duration, :annotation, to: :solr_document

    def attribute_to_html(field, options = {})
      options.merge!({:html_dl=> true})
      super(field, options)
    end
  end
end

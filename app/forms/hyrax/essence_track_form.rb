# Generated via
#  `rails generate hyrax:work EssenceTrack`
module Hyrax
  class EssenceTrackForm < Hyrax::Forms::WorkForm
    self.model_class = ::EssenceTrack
    self.terms += [:track_type, :track_id, :standard, :encoding, :data_rate, :frame_rate,:playback_inch_per_sec, :playback_frame_per_sec,
                   :sample_rate, :bit_depth, :frame_width, :frame_height, :time_start, :duration, :annotation]
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject,
                   :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:track_type, :track_id]
  end
end
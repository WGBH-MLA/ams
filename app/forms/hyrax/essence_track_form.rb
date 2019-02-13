# Generated via
#  `rails generate hyrax:work EssenceTrack`
module Hyrax
  class EssenceTrackForm < Hyrax::Forms::WorkForm
    include DisabledFields
    include InheritParentTitle

    self.model_class = ::EssenceTrack
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject,
                   :identifier, :based_near, :related_url, :bibliographic_citation, :source, :language]

    self.terms += [:track_id, :track_type, :standard, :encoding, :frame_rate, :data_rate, :playback_speed, :playback_speed_units,
                   :sample_rate, :bit_depth, :language, :aspect_ratio, :frame_width, :frame_height, :duration, :time_start, :annotation]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:track_type, :track_id]

    self.readonly_fields = [:title]

    self.field_metadata_service = AAPB::MetadataService

    def self.model_attributes(form_params)
      clean_params = sanitize_params(form_params)
      clean_params[:title] = Array(clean_params[:title])
      clean_params
    end
  end
end

# Generated via
#  `rails generate hyrax:work EssenceTrack`
module Hyrax
  class EssenceTrackForm < Hyrax::Forms::WorkForm
    include DisabledFields

    self.model_class = ::EssenceTrack
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject,
                   :identifier, :based_near, :related_url, :bibliographic_citation, :source, :language]

    self.terms += [:track_id, :track_type, :standard, :encoding, :frame_rate, :data_rate, :playback_inch_per_sec, :playback_frame_per_sec,
                   :sample_rate, :bit_depth, :language, :aspect_ratio, :frame_width, :frame_height, :duration, :time_start, :annotation]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:track_type, :track_id]

    self.readonly_fields = [:title]

    self.field_metadata_service = WGBH::MetadataService

    def title
      if @controller.params.has_key?(:parent_id)
        parent_object = ActiveFedora::Base.find(@controller.params[:parent_id])
        if(parent_object.title.any?)
          return [parent_object.title.first]
        end
      end
      []
    end

    def self.model_attributes(form_params)
      clean_params = sanitize_params(form_params)
      clean_params[:title] = Array(clean_params[:title])
      clean_params
    end
  end
end
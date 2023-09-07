# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource EssenceTrackResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class EssenceTrackResourceForm < Hyrax::Forms::ResourceForm(EssenceTrackResource)
  include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:essence_track_resource)
  include DisabledFields
  # TODO comment back in when we have a parent
  # include InheritParentTitle

  self.fields -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject,
                   :identifier, :based_near, :related_url, :bibliographic_citation, :source, :language]

  self.fields += [:track_id, :track_type, :standard, :encoding, :frame_rate, :data_rate, :playback_speed, :playback_speed_units,
                   :sample_rate, :bit_depth, :language, :aspect_ratio, :frame_width, :frame_height, :duration, :time_start, :annotation]

  self.required_fields -= [:creator, :keyword, :rights_statement]
  self.required_fields += [:track_type, :track_id]

  self.readonly_fields = [:title]

  def self.model_attributes(form_params)
    clean_params = sanitize_params(form_params)
    clean_params[:title] = Array(clean_params[:title])
    clean_params
  end

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true
end

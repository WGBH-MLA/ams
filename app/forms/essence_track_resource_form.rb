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
  include InheritParentTitle

  attr_accessor :controller, :current_ability

  self.readonly_fields = [:title]

  def self.model_attributes(form_params)
    clean_params = sanitize_params(form_params)
    clean_params[:title] = Array(clean_params[:title])
    clean_params
  end

  property :title, required: true, primary: true, multiple: false

  # remove fields from the form that are defined either from the
  # core metadata or basic metadata
  def self.remove(terms)
    terms.each do |term|
      property term, required: false, display: false
    end
  end
  remove(
    %i(
      based_near
      bibliographic_citation
      contributor
      creator
      date_created
      description
      identifier
      import_url
      keyword
      label
      language
      license
      publisher
      related_url
      relative_path
      resource_type
      rights_statement
      source
      subject
    )
  )

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true
end

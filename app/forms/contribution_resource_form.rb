# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ContributionResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class ContributionResourceForm < Hyrax::Forms::ResourceForm(ContributionResource)
  include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:contribution_resource)
  include SingleValuedForm
  include InheritParentTitle

  attr_accessor :controller, :current_ability

  self.single_valued_fields = [:title, :contributor]

  property :title, required: true, primary: true

  # remove fields from the form that are defined either from the
  # core metadata or basic metadata
  def self.remove(terms)
    terms.each do |term|
      property term, required: false, display: false
    end
  end
  remove(
    %i(
      affiliation
      based_near
      bibliographic_citation
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

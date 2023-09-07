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
  # TODO comment back in when we have a parent
  # include InheritParentTitle

  self.fields += [:contributor_role, :portrayal]
  self.fields -= [:language, :description, :relative_path, :import_url, :date_created, :resource_type, :creator, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
  self.required_fields -= [:creator, :keyword, :rights_statement]
  self.single_valued_fields = [:title, :contributor]

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true
end

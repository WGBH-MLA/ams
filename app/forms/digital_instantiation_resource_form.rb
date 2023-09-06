# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DigitalInstantiationResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class DigitalInstantiationResourceForm < Hyrax::Forms::ResourceForm(DigitalInstantiationResource)
  include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:digital_instantiation_resource)

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true
  property :parent_id, virtual: true

  def instantiation_admin_data
    @instantiation_admin_data_gid ||= InstantiationAdminData.find_by_gid(instantiation_admin_data_gid)
  end

  def instantiation_admin_data=(new_admin_data)
    self[:instantiation_admin_data_gid] = new_admin_data.gid
  end
end

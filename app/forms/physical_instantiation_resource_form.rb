# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource PhysicalInstantiationResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class PhysicalInstantiationResourceForm < Hyrax::Forms::ResourceForm(PhysicalInstantiationResource)
  # include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:physical_instantiation_resource)
  include DisabledFields
  include ChildCreateButton
  include SingleValuedForm
  # TODO comment back in when we have a parent
  include InheritParentTitle

  attr_accessor :controller, :current_ability

  self.required_fields += [:format, :location, :media_type, :holding_organization]

  self.single_valued_fields = [:title]

  #removing id, created_at & updated_at from attributes
  instantiation_admin_data_attributes = (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym

  class_attribute :field_groups

  self.field_groups = {
    identifying_info: [:title, :holding_organization, :local_instantiation_identifier, :media_type, :format, :location, :generations, :date, :digitization_date,
                       :language, :annotation],
    technical_info: [:dimensions, :standard, :duration, :time_start, :colors, :tracks, :channel_configuration,
                     :alternative_modes],
    rights: [:rights_summary, :rights_link],
    instantiation_admin_data: instantiation_admin_data_attributes
  }

  self.fields += (self.required_fields + field_groups.values.map(&:to_a).flatten).uniq

  self.readonly_fields = [:title]
  #self.disabled_fields =  instantiation_admin_data_attributes

  def primary_terms
    []
  end

  def secondary_terms
    []
  end

  def expand_field_group?(group)
    #Get terms for a certian field group
    field_group_terms(group).each do |term|
      #Get terms for a certian field group
      return true if group == :instantiation_admin_data && model.instantiation_admin_data && !model.instantiation_admin_data.empty?
      #Expand field group
      return true if !model.attributes[term.to_s].blank? || errors.has_key?(term)
    end
    false
  end

  property :aapb_preservation_lto, virtual: true
  def aapb_preservation_lto
    if model.instantiation_admin_data
      model.instantiation_admin_data.aapb_preservation_lto
    else
      ""
    end
  end

  def disabled?(field)
    disabled_fields = self.disabled_fields.dup
    # TODO: current_ability isn't a thing right now so I'm commenting this out for now
    # disabled_fields += self.field_groups[:instantiation_admin_data] if current_ability.cannot?(:create, InstantiationAdminData)
    disabled_fields.include?(field)
  end

  property :aapb_preservation_disk, virtual: true
  def aapb_preservation_disk
    if model.instantiation_admin_data
      model.instantiation_admin_data.aapb_preservation_disk
    else
      ""
    end
  end

  property :md5, virtual: true
  def md5
    if model.instantiation_admin_data
      model.instantiation_admin_data.md5
    else
      ""
    end
  end

  def field_group_terms(group)
    field_groups[group]
  end

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true

  def instantiation_admin_data
    @instantiation_admin_data_gid ||= InstantiationAdminData.find_by_gid(instantiation_admin_data_gid)
  end

  def instantiation_admin_data=(new_admin_data)
    self[:instantiation_admin_data_gid] = new_admin_data.gid
  end
end

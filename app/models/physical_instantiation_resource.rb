# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource PhysicalInstantiationResource`
class PhysicalInstantiationResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:physical_instantiation_resource)
  include Hyrax::ArResource
  include AMS::WorkBehavior
  include ::AMS::CreateMemberMethods

  self.valid_child_concerns = [EssenceTrackResource]

  # after_initialize does not work with Valkyrie apparently
  # so to get the #create_child_methods method to run
  # we have to call it like this
  def initialize(*args)
    super
    create_child_methods
  end

  def instantiation_admin_data
    return @instantiation_admin_data if @instantiation_admin_data

    if instantiation_admin_data_gid.present?
      @instantiation_admin_data = InstantiationAdminData.find_by_gid(instantiation_admin_data_gid)
    end

    @instantiation_admin_data
  end

  def instantiation_admin_data=(new_admin_data)
    self.instantiation_admin_data_gid = new_admin_data.gid
    @instantiation_admin_data = new_admin_data
  end
end

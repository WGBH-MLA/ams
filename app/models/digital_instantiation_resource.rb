# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DigitalInstantiationResource`
class DigitalInstantiationResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:digital_instantiation_resource)
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
    @instantiation_admin_data_gid ||= InstantiationAdminData.find_by_gid(instantiation_admin_data_gid)
  end

  def instantiation_admin_data=(new_admin_data)
    self.instantiation_admin_data_gid = new_admin_data.gid
  end
end

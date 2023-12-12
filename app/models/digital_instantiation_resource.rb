# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DigitalInstantiationResource`
require 'carrierwave/validations/active_model'

class DigitalInstantiationResource < Hyrax::Work
  attr_accessor :skip_file_upload_validation

  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:digital_instantiation_resource)
  include Hyrax::ArResource
  include AMS::WorkBehavior
  include ::AMS::CreateMemberMethods
  extend CarrierWave::Mount

  mount_uploader :digital_instantiation_pbcore_xml, PbCoreInstantiationXmlUploader

  self.valid_child_concerns = [EssenceTrackResource]

  # after_initialize does not work with Valkyrie apparently
  # so to get the #create_child_methods method to run
  # we have to call it like this
  def initialize(*args)
    super
    create_child_methods
  end

  def pbcore_validate_instantiation_xsd
    if digital_instantiation_pbcore_xml.file
      schema = Nokogiri::XML::Schema(File.read(Rails.root.join('spec', 'fixtures', 'pbcore-2.1.xsd')))
      document = Nokogiri::XML(File.read(digital_instantiation_pbcore_xml.file.file))
      schema.validate(document).each do |error|
        errors.add(:digital_instantiation_pbcore_xml, error.message)
      end
    elsif self.new_record? && !skip_file_upload_validation
      errors.add(:digital_instantiation_pbcore_xml,"Please select pbcore xml document")
    end
  end

  def instantiation_admin_data
    return @instantiation_admin_data if @instantiation_admin_data.present?

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

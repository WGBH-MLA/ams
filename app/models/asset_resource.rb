# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource AssetResource`
class AssetResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:asset_resource)
  include Hyrax::ArResource
  include AMS::WorkBehavior
  include AMS::CreateMemberMethods

  self.valid_child_concerns = [DigitalInstantiationResource, PhysicalInstantiationResource, ContributionResource]

  VALIDATION_STATUSES = {
    valid: 'valid',
    missing_children: 'missing child record(s)',
    status_not_validated: 'not yet validated',
    empty: 'missing a validation status'
  }.freeze

  # after_initialize does not work with Valkyrie apparently
  # so to get the #create_child_methods method to run
  # we have to call it like this
  def initialize(*args)
    create_child_methods
    super
  end

  def admin_data
    return @admin_data if @admin_data

    if admin_data_gid.present?
      @admin_data = AdminData.find_by_gid(admin_data_gid)
    end

    @admin_data ||= nil
  end

  def admin_data=(new_admin_data)
    self.admin_data_gid = new_admin_data.gid
    @admin_data = new_admin_data
  end

  def annotations
    @annotations ||= admin_data.annotations
  end

  def sonyci_id
    sonyci_id ||= find_admin_data_attribute("sonyci_id")
  end

  def supplemental_material
    supplemental_material ||= find_annotation_attribute("supplemental_material")
  end

  def organization
    organization ||= find_annotation_attribute("organization")
  end

  def level_of_user_access
    level_of_user_access ||= find_annotation_attribute("level_of_user_access")
  end

  def transcript_status
    transcript_status ||= find_annotation_attribute("transcript_status")
  end

  def transcript_url
    transcript_url ||= find_annotation_attribute("transcript_url")
  end

  def transcript_source
    transcript_source ||= find_annotation_attribute("transcript_source")
  end

  def cataloging_status
    cataloging_status ||= find_annotation_attribute("cataloging_status")
  end

  def captions_url
    captions_url ||= find_annotation_attribute("captions_url")
  end

  def last_modified
    licensing_info ||= find_annotation_attribute("last_modified")
  end

  def licensing_info
    licensing_info ||= find_annotation_attribute("licensing_info")
  end

  def outside_url
    outside_url ||= find_annotation_attribute("outside_url")
  end

  def external_reference_url
    external_reference_url ||= find_annotation_attribute("external_reference_url")
  end

  def mavis_number
    mavis_number ||= find_annotation_attribute("mavis_number")
  end

  def playlist_group
    playlist_group ||= find_annotation_attribute("playlist_group")
  end

  def playlist_order
    playlist_order ||= find_annotation_attribute("playlist_order")
  end

  def special_collections
    special_collection ||= find_annotation_attribute("special_collections")
  end

  def special_collection_category
    special_collection_category ||= find_annotation_attribute("special_collection_category")
  end

  def project_code
    project_code ||= find_annotation_attribute("project_code")
  end

  def canonical_meta_tag
    canonical_meta_tag ||= find_annotation_attribute("canonical_meta_tag")
  end

  def proxy_start_time
    proxy_start_time ||= find_annotation_attribute("proxy_start_time")
  end

  def find_annotation_attribute(attribute)
    if admin_data.annotations.select { |a| a.annotation_type == attribute }.present?
      return admin_data.annotations.select { |a| a.annotation_type == attribute }.map(&:value)
    else
      []
    end
  end

  def find_admin_data_attribute(attribute)
    if admin_data.try(attribute.to_sym).present?
      return [ admin_data.try(attribute.to_sym) ] unless admin_data.try(attribute.to_sym).is_a?(Array)
      return admin_data.try(attribute.to_sym)
    else
      []
    end
  end

  def set_validation_status
    current_children_count = SolrDocument.get_members(self).reject { |child| child.is_a?(Contribution) || child.id == self.id }.size
    intended_children_count = self.intended_children_count.to_i

    self.validation_status_for_aapb = if intended_children_count.blank? && self.validation_status_for_aapb.blank?
       [Asset::VALIDATION_STATUSES[:status_not_validated]]
    elsif current_children_count < intended_children_count
       [Asset::VALIDATION_STATUSES[:missing_children]]
    else
       [Asset::VALIDATION_STATUSES[:valid]]
    end
  end
end

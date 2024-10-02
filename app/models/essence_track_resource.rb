# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource EssenceTrackResource`
class EssenceTrackResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:essence_track_resource)
  include Hyrax::ArResource
  include AMS::WorkBehavior

  VALIDATION_STATUSES = {
    valid: 'valid',
    track_missing: 'track id or track type is missing',
  }.freeze

  self.valid_child_concerns = []

  def aapb_valid?
    track_id.present? && track_type.present?
  end

  def aapb_invalid_message
    "#{self.id} track id or track type is missing" unless aapb_valid?
  end
end

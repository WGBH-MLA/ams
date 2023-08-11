# frozen_string_literal: true

class BackfillAssetValidationStatusJob < ApplicationJob
  queue_as :backfill_validations

  def perform(asset_id, attrs_for_actor)
    asset = Asset.find(asset_id)
    # Generic admin user we can count on existing
    user = User.find_by(email: 'wgbh_admin@wgbh-mla.org')
    actor = Hyrax::CurationConcern.actor
    env = Hyrax::Actors::Environment.new(asset, Ability.new(user), attrs_for_actor)

    actor.update(env)
  rescue => e
    logger.error("Asset update failed! | #{e.class} | #{e.message} | #{asset_id}")
    raise e
  end

  # This logger is shared with AMS::BackfillAssetValidationStatus
  def logger
    @logger ||= ActiveSupport::Logger.new(
      AMS::BackfillAssetValidationStatus::LOGGER_PATH
    )
  end
end

class ExportRecordsJob < ApplicationJob
  queue_as :default

  include Blacklight::Configurable
  include Blacklight::SearchHelper

  class_attribute :current_ability

  copy_blacklight_config_from(CatalogController)

  # @param [Hash] search params
  # @param [User] user
  def perform(search_params, user)
    self.current_ability = Ability.new(user)

    search_params[:rows] = 1_000_000_000
    response, response_documents = search_results(search_params)

    if search_params[:format] == "csv"
      export_data = AMS::Export::DocumentsToCsv.new(response_documents)
    elsif search_params[:format] == "pbcore"
      export_data = AMS::Export::DocumentsToPbcoreXml.new(response_documents)
    elsif search_params[:format] == 'zip-pbcore'
      Sidekiq::Logging.logger.warn "Generating ZIPP PBCORE THING"
      export_data = AMS::Export::DocumentsToZippedPbcore.new(response_documents)
    else
      raise "Unknown export format"
    end

    # new zip method
    if search_params[:format] == 'zip-pbcore'
      # TODO: add notification for aapb copy
      # use @file_path var to send zip from tmp location to aapb
      Sidekiq::Logging.logger.warn "Ready to run scp_to_aapb"
      export_data.scp_to_aapb
    else
      # upload zip to s3 for download
      export_data.upload_to_s3
      Ams2Mailer.export_notification(user, export_data.s3_path).deliver_later
    end

  end
end

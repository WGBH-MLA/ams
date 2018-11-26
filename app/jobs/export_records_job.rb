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
    else
      raise "Unknown export format"
    end

    export_data.process do
      export_data.upload_to_s3
    end

    Ams2Mailer.export_notification(user, export_data.s3_path).deliver_later
  end
end

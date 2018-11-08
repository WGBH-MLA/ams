class ExportRecordsJob < Hyrax::ApplicationJob
  include Blacklight::Configurable
  include Blacklight::SearchHelper

  queue_as Hyrax.config.ingest_queue_name

  class_attribute :current_ability

  before_enqueue do |job|
    #operation = job.arguments.last
    #operation.pending_job(self)
    #

  end

  # This copies metadata from the passed in attribute to all of the works that
  # are members of the given upload set
  # @param [User] user
  # @param [Hash] search params
  def perform(search_params, user)

    self.current_ability = Ability.new(user)

    search_params[:rows] = 1000000000
    response, response_documents = search_results(search_params)

    if search_params[:format] == "csv"

      csv_export = AMS::Export::DocumentsToCsv.new(response_documents)
      csv_export.process
      export_url = csv_export.upload_to_s3


    elsif search_params[:format] == "pbcore"
      pbcore_xml_export = AMS::Export::DocumentsToPbcoreXml.new(response_documents)
      pbcore_xml_export.process
      export_url = csv_export.upload_to_s3
    else
      raise "Unknown export format"
    end

    Ams2Mailer.export_notification(user,export_url).deliver_later

  end

  private

  def upload_file_to_s3

  end

  def notify_user

  end
end

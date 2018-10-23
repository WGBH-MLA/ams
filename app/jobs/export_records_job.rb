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

    Aws.config.update({
                          region: 'us-east-1',
                          credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY']),
                      })
    s3 = Aws::S3::Resource.new(region:'us-east-1')
    export_url = ""

    if(search_params[:format] == "csv")

      csv_export = AMS::Export::DocumentsToCsv.new(response_documents)
      csv_export.process
      export_file = File.read(csv_export.file_path)
      # send file to s3
      obj = s3.bucket(ENV['S3_EXPORT_BUCKET']).object("#{ENV['S3_EXPORT_DIR']}/#{SecureRandom.uuid}/#{csv_export.filename}")
      File.open(csv_export.file_path, 'r') do |f|
        obj.upload_file(f, {acl:'public-read',content_disposition:'attachment'})
      end
      export_url = obj.public_url
      csv_export.clean

    elsif (search_params[:format] == "pbcore")
      # get pbcore here
      #
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

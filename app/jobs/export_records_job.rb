class ExportRecordsJob < ApplicationJob
  # Sepcify queue name
  queue_as :default

  # Include Blacklight modules that provide methods for configurating and
  # performing searches.
  include Blacklight::Configurable
  include Blacklight::SearchHelper

  class_attribute :current_ability

  copy_blacklight_config_from(CatalogController)

  # @param [Hash] search params
  # @param [User] user
  def perform(search_params, user)
    self.current_ability = Ability.new(user)

    format = search_params.delete :format
    response, response_documents = search_results(search_params)

    if format == "csv"
      object_type = search_params.delete :object_type
      export_data = AMS::Export::DocumentsToCsv.new(response_documents, object_type: object_type)
    elsif format == "pbcore"
      export_data = AMS::Export::DocumentsToPbcoreXml.new(response_documents)
    elsif format == 'zip-pbcore'

      assets = response_documents.map {|doc| Asset.find(doc[:id])}
      assets.each do |asset|
        now = Time.now.to_i

        admindata = asset.admin_data
        if admindata
          admindata.last_pushed = now
          admindata.needs_update = false
          admindata.save!
          admindata = nil
        end
      end

      # separating this from above because index update happens faster than admindata save
      assets.each do |asset|
        asset.update_index
      end

      export_data = AMS::Export::DocumentsToZippedPbcore.new(response_documents)
    else
      raise "Unknown export format"
    end

    # new zip method
    if format == 'zip-pbcore'

      # use @file_path var to send zip from tmp location to aapb
      export_data.process do
        export_data.scp_to_aapb(user)
      end
    else
      # upload zip to s3 for download
      export_data.process do
        export_data.upload_to_s3
      end
      Ams2Mailer.export_notification(user, export_data.s3_path).deliver_later
    end

  end
end

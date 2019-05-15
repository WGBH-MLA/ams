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

    format = search_params[:format]
    search_params.delete(:format)
    response, response_documents = search_results(search_params)
    
    if format == "csv"
      export_data = AMS::Export::DocumentsToCsv.new(response_documents)
    elsif format == "pbcore"
      export_data = AMS::Export::DocumentsToPbcoreXml.new(response_documents)
    elsif format == 'zip-pbcore'
      
      update_docs = response_documents.map do |doc|

        admindata = Asset.find(doc[:id]).admin_data
        if admindata
          admindata.last_pushed = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
          admindata.save!
          admindata = nil
        end
        # env = Hyrax::Actors::Environment.new(asset, current_ability, attrs)
        # actor.update(env)
        doc.delete(:score)
        doc.delete(:_version)
        doc[:last_pushed] = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
        doc._source
      end

      ActiveFedora::SolrService.add(update_docs, commit: true)

      export_data = AMS::Export::DocumentsToZippedPbcore.new(response_documents)
    else
      raise "Unknown export format"
    end

    # new zip method
    if format == 'zip-pbcore'
      # TODO: add notification for aapb copy
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

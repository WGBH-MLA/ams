class ExportRecordsJob < ApplicationJob
  # Sepcify queue name
  queue_as :default

  # Include Blacklight modules that provide methods for configurating and
  # performing searches.
  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include ApplicationHelper

  class_attribute :current_ability
  
  # this v is required - advanced_search will crash without it
  copy_blacklight_config_from(CatalogController)
  configure_blacklight do |config|
    # This is necessary to prevent Blacklight's default value of 100 for
    # config.max_per_page from capping the number of results.
    config.max_per_page = Rails.application.config.max_export_limit
  end

  # @param [Hash] search params
  # @param [User] user
  def perform(search_params, user)
    self.current_ability = Ability.new(user)
    format = search_params.delete :format
    
    # these push queries can be huge (500+), so slice up id queries to kid-size pieces
    if format == 'zip-pbcore' 

      ids = search_params[:q].gsub('id:', '').split(' OR ')
      response_documents = [] 
      docs = nil

      ids.each_slice(100).each do |segment|
        query = build_query(segment)
        docs = query_docs(query)
        response_documents += docs
      end

    else

      # nothing to see here, folks!
      response, response_documents = search_results({}) do |builder|
        AMS::PushSearchBuilder.new(self).with(search_params)
      end
    end

    if format == "csv"
      object_type = search_params.delete :object_type
      AMS::Export::DocumentsToCsv.new(response_documents, object_type: object_type, export_type: 'csv_job')
    elsif format == "pbcore"
      AMS::Export::DocumentsToPbcoreXml.new(response_documents, export_type: 'pbcore_job')
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

      AMS::Export::DocumentsToPushedZip.new(response_documents, export_type: 'pushed_zip_job', user: user)
    else
      raise "Unknown export format"
    end

  end
end

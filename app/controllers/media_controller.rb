require 'sony_ci_api'

class MediaController < ApplicationController
  def show
    if solr_document
      if can? :show, solr_document
        redirect_to download_url
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end

  private

    def download_url
      @download_url ||= begin
        download_response = ci.asset_download(solr_document['sonyci_id_ssim'][(params['part'] || 0).to_i])
        download_response['location']
      end
    end

    def ci
      @ci ||= SonyCiApi::Client.new('config/ci.yml')
    end

    def solr_document
      @solr_document ||= ActiveFedora::Base.find(params['id']).to_solr
    rescue ActiveFedora::ObjectNotFoundError
      nil
    end
end

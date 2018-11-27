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
      @download_url ||= ci.download(solr_document['sonyci_id_tesim'][(params['part'] || 0).to_i])
    end

    def ci
      credentials = YAML.load(ERB.new(File.read('config/ci.yml')).result)
      @ci ||= SonyCiBasic.new(credentials:credentials)
    end

    def solr_document
      @solr_document ||= ActiveFedora::Base.find(params['id']).to_solr
    rescue ActiveFedora::ObjectNotFoundError
      nil
    end
end

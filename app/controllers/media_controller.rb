require 'sony_ci_api'

class MediaController < ApplicationController

  rescue_from StandardError, with: :error_response_default
  rescue_from Blacklight::Exceptions::RecordNotFound, with: :error_response_404
  rescue_from SonyCiApi::HttpError, with: :error_response_from_sony_ci

  def show
    head(:forbidden) and return unless can? :show, solr_document
    head(:not_found) and return unless download_url
    redirect_to download_url and return
  end

  private

    # Returns the download_url (aka the 'location') of the media for the Solr
    # document's Sony Ci ID
    def download_url
        sony_ci_response['location']
    end

    # Fetches the response from the actual Sony Ci api.
    def sony_ci_response
      @sony_ci_response ||= ci.asset_download(sony_ci_id)
    end

    # Returns the Sony Ci ID from the list of Sony Ci IDs in the multi-valued
    # sonyci_id_ssim Solr field; nil if the sonyci_id_ssim field is empty.
    def sony_ci_id
      sony_ci_ids = solr_document['sonyci_id_ssim']
      if sony_ci_ids.present?
        # `part` defaults to 0 if `params['part']` is nil.
        part = params['part'].to_i
        sony_ci_ids[part]
      end
    end

    def ci
      @ci ||= SonyCiApi::Client.new('config/ci.yml')
    end

    def solr_document
      @solr_document ||= SolrDocument.find(params['id'])
    end

    ################
    # Error handling
    ################
    def error_response_default(error)
      log_error error
      head :internal_server_error
    end

    def error_response_404(error)
      log_error error
      head :not_found
    end

    def error_response_from_sony_ci(error)
      log_error error
      head error.http_status
    end

    def log_error(error)
      Rails.logger.error(error.class) { error.message }
    end
end

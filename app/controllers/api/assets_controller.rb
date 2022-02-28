module API
  class AssetsController < APIController
    # Authenticate user before all actions.
    # NOTE: For Basic HTTP auth to work:
    #   * the `http_authenticatable` config option for Devise must be set to true
    #     (see config/initializers/devise.rb).
    #   * The Authorization request header must be set to "Basic {cred}" where
    #     {cred} is the base64 encoded username:password.
    # TODO: Move authn into base APIController class and make modifications so
    # that the SonyCi::APIController will work with authn, which needs to be
    # done.
    before_action do
      authenticate_user!
    end


    def show
      respond_to do |format|
        format.json { render json: pbcore_json }
        format.xml { render xml: pbcore_xml }
      end
    end

    private

    def pbcore_json
      @pbcore_json ||= Hash.from_xml(pbcore_xml).to_json
    end

    def pbcore_xml
      @pbcore_xml ||= solr_doc.export_as_pbcore
    end

    def solr_doc
      @solr_doc ||= SolrDocument.find(params[:id])
    end
  end
end

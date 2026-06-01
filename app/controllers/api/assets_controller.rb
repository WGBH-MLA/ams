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

    def link_media
      asset_resource.admin_data.update!(sonyci_id: found_sony_ci_id) && asset_resource.save!
    rescue => e
      render json: { "error" => e.class.to_s, "error_message" => e.message }, status: 500
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

    def found_sony_ci_id
      result = ci.workspace_search(
        query: aapb_id_str_for_query,
        fields: ['id', 'name'],
        kind: "Asset"
      )
      render json: result
    end

    def aapb_id_str_for_query
      permitted_params.require(:aapd_id).sub("cpb-aacip-", "")[0..19]
    end

    def ci
      @ci ||= SonyCiApi::Client.new('config/ci.yml')
    end
  end
end

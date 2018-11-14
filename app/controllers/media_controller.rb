require 'sony_ci_api'

class MediaController < ApplicationController
  before_action :set_solr_document

  def show
    ci = SonyCiBasic.new(credentials_path: Rails.root + 'config/ci.yml')
    redirect_to ci.download(@solr_document['sonyci_id_tesim'][(params['part'] || 0).to_i])
  end

  private

  def set_solr_document
    @solr_document = ActiveFedora::Base.find(params['id']).to_solr
    raise "Unable to find SolrDocument with ID=#{params['id']}" if @solr_document.nil?
    @solr_document
  end
end

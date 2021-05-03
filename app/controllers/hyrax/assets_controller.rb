# Generated via
#  `rails generate hyrax:work Asset`

module Hyrax
  class AssetsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Adds behaviors for hyrax-iiif_av plugin.
    # include Hyrax::IiifAv::ControllerBehavior
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Asset

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::AssetPresenter

    def download_media
      respond_to do |format|
        format.zip {
          export_data = AMS::MediaDownload::MediaDownloadService.new(solr_document)
          export_data.process do
            export_file = File.read(export_data.file_path)
            send_data export_file, :type => 'application/zip', :filename => "#{export_data.filename}"
          end
        }
      end
    end

    def destroy
      if current_user.can? :destroy, Asset
        super
      else
        flash[:error] = 'You are not permitted to do that!'
        redirect_to request.path
      end
    end

    private

      def solr_document
        ::SolrDocument.find(presenter.id)
      end

      # This extends functionality from
      # Hyrax::WorksControllerBehavior#additional_response_formats, adding a
      # response for a ".xml" extension, returning the PBCore XML.
      def additional_response_formats(format)
        format.xml { render(plain: presenter.solr_document.export_as_pbcore) }
        super
      end
  end
end

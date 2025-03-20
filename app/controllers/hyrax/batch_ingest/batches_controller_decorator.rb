# frozen_string_literal: true

# OVERRIDE HYRAX-Batch_Ingest revision: dc9d38039728eab581ab7b1cb55cf9ff33984b13
# disable /batches endpoint for new creation. Redirect to bulkrax's importer paths

module Hyrax
  module BatchIngest
    module BatchesControllerDecorator
      def new
        # OVERRIDE HYRAX-Batch_Ingest revision: dc9d38039728eab581ab7b1cb55cf9ff33984b13
        if ENV['SETTINGS__BULKRAX__ENABLED'] == 'false'
          super
        else
          redirect_to '/importers/new'
        end
      end

      def create
        # OVERRIDE HYRAX-Batch_Ingest revision: dc9d38039728eab581ab7b1cb55cf9ff33984b13
        if ENV['SETTINGS__BULKRAX__ENABLED'] == 'false'
          super
        else
          redirect_to '/importers/new'
        end
      end

      def index
        # OVERRIDE HYRAX-Batch_Ingest revision: dc9d38039728eab581ab7b1cb55cf9ff33984b13
        if ENV['SETTINGS__BULKRAX__ENABLED'] == 'false'
          super
        else
          redirect_to '/importers'
        end
      end

      private

      # Added to allow authorization of batches in Hyrax's my_controller.
      #   before_action :custom_load_and_authorize, only: :show

      # MyController is used by both collections and batch ingest so we needed
      # to add this method to allow for the correct authorization
      # def custom_load_and_authorize
      #   if self.class == Hyrax::BatchIngest::BatchesController
      #       authorize_show_batch
      #   else
      #     @object = Hyrax.query_service.find_by(id: params[:id])
      #     return false unless @object
      #     authorize! :read, @object
      #   end
      # end
      def authorize_show_batch
        @batch = Batch.find(params[:id])
        return false unless @batch
        authorize! :show, @batch
      end
    end
  end
end
Hyrax::BatchIngest::BatchesController.prepend(Hyrax::BatchIngest::BatchesControllerDecorator)

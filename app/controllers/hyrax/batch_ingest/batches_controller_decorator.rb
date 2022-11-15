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
    end
  end
end
Hyrax::BatchIngest::BatchesController.prepend(Hyrax::BatchIngest::BatchesControllerDecorator)

# frozen_string_literal: true

# OVERRIDE HYRAX-Batch_Ingest revision: dc9d38039728eab581ab7b1cb55cf9ff33984b13
# disable /batches endpoint for new creation. Redirect to bulkrax's importer paths

require_dependency Hyrax::BatchIngest::Engine.root.join('app', 'controllers', 'hyrax', 'batch_ingest', 'batches_controller').to_s

Hyrax::BatchIngest::BatchesController.class_eval do
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

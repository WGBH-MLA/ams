# frozen_string_literal: true
require 'hyrax/batch_ingest/batch_presenter'

module Hyrax
  module BatchIngest
    class BatchPresenter
      # Module for adding/modifying behaviors of
      # Hyrax::BatchIngest::BatchPresenter
      module Overrides
        # Overrides Hyrax::BatchIngest::BatchPresenter#batch_actions.
        # Original method definition is in hyrax-batch_ingest gem at:
        #   app/presenters/hyrax/batch_ingest/batch_presenter.rb
        # Here we want to add the 'View All Assets' link
        def batch_actions
          [
            { text: "List View", url: "/batches/#{id}" },
            { text: "Summary View", url: "/batches/#{id}/summary" },
            { text: "View All Assets", url: "/catalog?f[hyrax_batch_ingest_batch_id_tesim][]=#{id}&locale=en&q=&search_field=all_fields" }
          ].each do |action|
            action[:active] = true if request&.path == action[:url]
          end
        end
      end

      # Include the overrides.
      include Overrides
    end
  end
end

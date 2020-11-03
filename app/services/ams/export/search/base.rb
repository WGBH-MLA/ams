module AMS
  module Export
    module Search
      # Performs a Blacklight serach similar to CatalogController with a couple
      # of additional features:
      # 1. Contains conditional logic that determines whether to run a second
      #    search to fetch the members (i.e. Physical or Digital instantiations)
      #    of an Asset.
      # 2. Performs a pre-flight search returning 0 rows, but checking the numFound to
      #    to get the export size (in records).
      # The export searches need to be done both in CatalogController and in
      # export jobs, hence the abstraction into this class.
      class Base

        # Include Blacklight modules that provide methods for configurating and
        # performing searches.
        include Blacklight::SearchHelper
        include Blacklight::Configurable
        include ActiveModel::Validations

        MAX_LIMIT = Rails.configuration.max_export_limit

        # this is required - advanced_search will crash without it
        copy_blacklight_config_from(CatalogController)
        configure_blacklight do |config|
          # This is necessary to prevent Blacklight's default value of 100 for
          # config.max_per_page from capping the number of results.
          config.max_per_page = MAX_LIMIT
        end

        attr_reader :user, :search_params

        def initialize(search_params:, user:)
          @search_params = search_params
          @user = user
        end

        validate do |search|
          errors.add(:base, "Export of size #{search.num_found} is too large. Max " \
                            "export limit is #{MAX_LIMIT}.") if (search.num_found > MAX_LIMIT)
        end

        # Used by Blacklight::AccessControls because we have to bring Blacklight's
        # search interface into this class.
        def current_ability; Ability.new(user); end

        def solr_documents
          response.fetch('response').fetch('docs').map do |solr_response_hash|
            SolrDocument.new(solr_response_hash)
          end
        end

        def num_found
          response_without_rows.fetch('response').fetch('numFound').to_i
        end

        private

          def response
            raise "#{self.class}##{__method__} must be implemented to return " \
                  "a Solr response including all results."
          end

          def response_without_rows
            raise "#{self.class}##{__method__} must be implemented to " \
                  "return a Solr response without any documents by " \
                  "setting the :rows search parameter to 0."
          end
      end
    end
  end
end

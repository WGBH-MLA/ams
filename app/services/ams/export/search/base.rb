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
        include ActiveModel::Validations
        include Blacklight::Configurable

        MAX_LIMIT = Rails.configuration.max_export_limit

        attr_reader :user, :search_params

        def initialize(search_params:, user:)
          # Set rows: MAX_LIMIT in search params to return all rows by default.
          @search_params = search_params.merge(rows: MAX_LIMIT)
          @user = user
        end

        validate do |search|
          errors.add(:base, "Export of size #{num_found} is too large. Max " \
                            "export limit is #{MAX_LIMIT}.") if (num_found > MAX_LIMIT)
        end

        def current_ability
          @current_ability ||= Ability.new(user)
        end

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
            @response ||= repository.search(search_params)
          end

          def response_without_rows
            @response_without_rows ||= repository.search(search_params.merge(rows: 0))
          end

          def repository
            @repository ||= Blacklight::Solr::Repository.new(blacklight_config)
          end
      end
    end
  end
end

module AMS
  class SearchBuilder < Hyrax::CatalogSearchBuilder
    include BlacklightAdvancedSearch::AdvancedSearchBuilder

    # Add date filters to the processor chain.
    self.default_processor_chain += [:apply_date_filter,:add_advanced_parse_q_to_solr]

    # Overrides Hyrax::FilterModels.
    def models
      [Asset]
    end

    # Adds date filters to the :fq of the solr params.
    def apply_date_filter(solr_params)
      if date_filters
        solr_params[:fq] ||= []
        solr_params[:fq] << "(#{date_filters.join(" OR ")})"
      end
      solr_params
    end

    ##
    # @example Adding a new step to the processor chain
    #   self.default_processor_chain += [:add_custom_data_to_query]
    #
    #   def add_custom_data_to_query(solr_parameters)
    #     solr_parameters[:custom] = blacklight_params[:user_value]
    #   end

    private

      # Returns the array of date filters, which are joined with ' OR ' as part
      # of a 'fq' parameter. See apply_date_filter above.
      def date_filters
        @date_filters ||= begin
          if date_range
            # Map the date field names to the search condition that includes
            # the date field name and the date range.
            date_field_names.map do |date_field|
              # NOTE: We need to use _query_ (i.e. nested queries) because for
              # some mysterious reason, Solr cannot parse the queries after we
              # join them with ' OR ' -- it doesn't seem to like the spaces.
              # But using nested queries here magically works. ¯\_(ツ)_/¯
              "_query_:\"{!field f=#{date_field} op=Within}[#{date_range}]\""
            end
          end
        end
      end

      # Returns the 'before' date time formatted for a Solr query.
      def before_date
        @before_date ||= formatted_date(blacklight_params['before_date'])
      end

      # Returns the 'after' date time formatted for a Solr query.
      def after_date
        @after_date ||= formatted_date(blacklight_params['after_date'])
      end

      # Returns the date inputs in the form of a queryable range.
      def date_range
        @date_range ||= if filter_exact_date?
          if after_date
            "#{after_date} TO #{after_date}"
          end
        else
          if before_date || after_date
            "#{after_date || '*'} TO #{before_date || '*'}"
          end
        end
      end

      # Converts an unformatted date (as passed in via URL) to a date formatted
      # for a Solr query.
      def formatted_date(unformatted_date)
        DateTime.parse(unformatted_date.to_s).utc.strftime("%Y-%m-%d")
      rescue ArgumentError => e
        nil
      end

      def filter_exact_date?
        blacklight_params['exact_or_range'] == 'exact'
      end

      def date_field_names
        ['date_drsim', 'broadcast_date_drsim', 'created_date_drsim', 'copyright_date_drsim']
      end
  end
end

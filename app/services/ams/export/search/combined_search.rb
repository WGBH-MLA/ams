module AMS
  module Export
    module Search
      class CombinedSearch
        attr_reader :searches
        def initialize(searches: [])
          @searches = Array(searches)
        end

        # Returns the sum of all num_found values for each search
        # NOTE: This count does not exclucde duplicate results that may be
        # returned from different searches, whereas the solr_documents method, by
        # default, will remove duplicates. Thus the num_found will only be the
        # same as the count of actual solr_documents if all searches produce
        # disjoint result sets.
        def num_found
          @num_found ||= searches.map(&:num_found).map(&:to_i).sum
        end

        # Returns an array of SolrDocument instances from the Search classes.
        # NOTE:
        def solr_documents
          @solr_documents ||= searches.map(&:solr_documents).flatten.uniq { |solr_doc| solr_doc['id'] }
        end
      end
    end
  end
end

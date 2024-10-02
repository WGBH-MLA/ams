# app/helpers/solr_helper.rb
module SolrHelper
  def solr_name(field_name, *opts)
    if Module.const_defined?(:Solrizer)
      ::Solrizer.solr_name(field_name, *opts)
    else
      ::ActiveFedora.index_field_mapper.solr_name(field_name, *opts)
    end
  end
end

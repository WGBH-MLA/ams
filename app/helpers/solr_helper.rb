# app/helpers/solr_helper.rb
module SolrHelper
  def solr_name(base_name)
    if Module.const_defined?(:Solrizer)
      ::Solrizer.solr_name(base_name)
    else
      ::ActiveFedora.index_field_mapper.solr_name(base_name)
    end
  end
end

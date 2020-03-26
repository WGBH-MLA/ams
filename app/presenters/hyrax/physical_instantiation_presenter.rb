# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationPresenter < Hyrax::WorkShowPresenter
    include AAPB::InstantiationAdminDataPresenter

    delegate :date, :digitization_date, :dimensions, :format, :standard, :location, :media_type, :generations, :time_start, :duration, :colors,
             :language, :rights_summary, :rights_link, :annotation, :local_instantiation_identifier, :tracks, :channel_configuration,
             :alternative_modes, :holding_organization, :aapb_preservation_lto, :aapb_preservation_disk, to: :solr_document


    def attribute_to_html(field, options = {})
      options.merge!({:html_dl=> true})

      if attribute_indexed_to_parent?(field) && attribute_facetable?(field)
        # Use :symbol for field_name since all attributes indexed to parent are indexed as symbols.
        field_name = Solrizer.solr_name(field, :symbol)
        # Use parent SolrDocument to get value
        solr_document = ::SolrDocument.find(PhysicalInstantiation.find(id).member_of.first.id)

        # Get values from sol_doc, should always be an Array since Assets can always have mutiple Instantiations
        values = solr_document[field_name] || Array.new
        return Hyrax::Renderers::IndexedToParentRenderer.new(field, values, options).render
      else
        return super(field, options)
      end
    end

    def attributes_indexed_to_parent
      PhysicalInstantiation.properties.select{ |k,v| v["index_to_parent"] == true unless v["index_to_parent"].nil? }
    end

    def attribute_indexed_to_parent?(field)
      return true unless attributes_indexed_to_parent[field.to_s].nil?
      false
    end

    def attribute_facetable?(field)
      return true unless facetable_attributes[field.to_s].nil?
      false
    end

    def facetable_attributes
      PhysicalInstantiation.properties.select{ |k,v| v["behaviors"].include? :facetable unless v["behaviors"].nil? }
    end
  end
end

module AAPB
  module AttributeIndexedToParentPresenter
    # @return [Boolean] true if the given field is indexed to the parent for the
    # given work class, false otherwise.
    def attribute_indexed_to_parent?(field, work_class)
      attributes_indexed_to_parent(work_class).include? field.to_s
    end

    # @return [Boolean] true if the given field is facetable for the given work
    #   class, false otherwise.
    def attribute_facetable?(field)
      facetable_attributes.include?(field.to_s)
    end

    private

    # @return [Array<String>] a list of attributes for the given work class that
    # are indexed to the parent.
    def attributes_indexed_to_parent(work_class)
      work_class.schema.select do |field_config|
       field_config.meta['index_to_parent'] == true
      end.map(&:name).map(&:to_s)
    end

    # @return [Array<String>] a list of facetable attributes according to the
    # Blacklight configuration on the CatalogController.
    def facetable_attributes
      CatalogController.blacklight_config.facet_fields.keys.map do |solr_facet_field|
        # The solr_facet_field is the field name plus the solr suffix so we drop
        # the solr suffix here to compare to the attribute name of the work
        # class.
        solr_facet_field.split('_')[0..-2].join('_')
      end.map(&:to_s)
    end

    # @return [Array<String>] a list of attributes for the given work class.
    def attribute_names(work_class)
      work_class.schema.map(&:name).map(&:to_s)
    end
  end
end

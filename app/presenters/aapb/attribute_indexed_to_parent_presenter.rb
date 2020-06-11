module AAPB
  module AttributeIndexedToParentPresenter
    def attribute_indexed_to_parent?(field, work_class)
      return true unless attributes_indexed_to_parent(work_class)[field.to_s].nil?
      false
    end

    def attribute_facetable?(field, work_class)
      return true unless facetable_attributes(work_class)[field.to_s].nil?
      false
    end

    private

    def attributes_indexed_to_parent(work_class)
      return nil unless work_class <= ActiveFedora::Base
      work_class.properties.select{ |k,v| v["index_to_parent"] == true unless v["index_to_parent"].nil? }
    end

    def facetable_attributes(work_class)
      return nil unless work_class <= ActiveFedora::Base
      work_class.properties.select{ |k,v| v["behaviors"].include? :facetable unless v["behaviors"].nil? }
    end

  end
end
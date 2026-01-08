module AAPB
  module AttributeIndexedToParentPresenter
    def attribute_indexed_to_parent?(field, work_class)
      attributes = attributes_indexed_to_parent(work_class)
      attributes && attributes.key?(field.to_s)
    end

    def attribute_facetable?(field, work_class)
      attributes = facetable_attributes(work_class)
      attributes && attributes.key?(field.to_s)
    end

    private

    def attributes_indexed_to_parent(work_class)
      # Check if this is a Valkyrie Resource
      return {} unless work_class.ancestors.include?(Valkyrie::Resource)

      # Build hash of attributes that have index_to_parent: true
      attributes = {}
      work_class.fields.each do |field_name|
        schema_key = work_class.schema.key(field_name)
        next unless schema_key

        meta = schema_key.meta
        if meta && meta['index_to_parent'] == true
          attributes[field_name.to_s] = meta
        end
      end

      attributes
    end

    def facetable_attributes(work_class)
      # Check if this is a Valkyrie Resource
      return {} unless work_class.ancestors.include?(Valkyrie::Resource)

      # Build hash of attributes that have _sim in their index_keys
      attributes = {}
      work_class.fields.each do |field_name|
        schema_key = work_class.schema.key(field_name)
        next unless schema_key

        meta = schema_key.meta
        next unless meta

        # Check if index_keys contains any key ending with _sim
        index_keys = meta['index_keys']
        if index_keys && index_keys.is_a?(Array)
          has_sim_key = index_keys.any? { |key| key.to_s.end_with?('_sim') }
          attributes[field_name.to_s] = meta if has_sim_key
        end
      end

      attributes
    end

  end
end

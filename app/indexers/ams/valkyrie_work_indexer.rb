module AMS
  class ValkyrieWorkIndexer < Hyrax::ValkyrieWorkIndexer
    include SolrHelper

    def to_solr
      find_index_child_attributes(super)
    end

    private

    def find_index_child_attributes(solr_doc)
      resource.members.each do |child|
        parent_indexable_properties = ["language", "contributor"]
        child.class.fields.each do |field_name|
          parent_indexable_properties << field_name if child.class.schema.key(field_name).meta['index_to_parent']
        end

        parent_indexable_properties.uniq.each do |prop|
          values = Array.wrap(child.send(prop))

          merge_values(solr_doc, "#{child.class.to_s.underscore}_#{prop}_ssim", values)

          # Searchable and facetable copies, matching what the catalog queries
          %w[ssim tesim sim].each do |suffix|
            merge_values(solr_doc, "#{prop}_#{suffix}", values)
          end
        end
      end
      solr_doc
    end

    def merge_values(solr_doc, key, values)
      solr_doc[key] ||= []
      solr_doc[key] |= values
    end
  end
end
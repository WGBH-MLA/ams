module AMS
  class ValkyrieWorkIndexer < Hyrax::ValkyrieWorkIndexer
    include SolrHelper

    def to_solr
      find_index_child_attributes(super)
    end

    private
    def find_index_child_attributes(solr_doc)
      resource.members.each do |child|
        parent_indexable_properties = [ "language", "contributor"]
        child.class.fields.each do |field_name|
          parent_indexable_properties << field_name if child.class.schema.key(field_name).meta['index_to_parent']
        end
        parent_indexable_properties.uniq.each do |prop|
          solr_doc["#{child.class.to_s.underscore}_#{prop}_ssim"] ||= []
          solr_doc["#{child.class.to_s.underscore}_#{prop}_ssim"] |= Array.wrap(child.send(prop))
          solr_doc["#{prop}_ssim"] ||= []
          solr_doc["#{prop}_ssim"] |= Array.wrap(child.send(prop))
        end
      end
      solr_doc
    end
  end
end

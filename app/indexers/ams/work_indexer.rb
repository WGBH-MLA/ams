module AMS
  class WorkIndexer < Hyrax::WorkIndexer
    def generate_solr_document
      find_index_child_attributes(super)
    end
    private
      def find_index_child_attributes(solr_doc)
        if solr_doc["member_ids_ssim"]
          child_works = solr_doc["member_ids_ssim"]
          child_works.each do |child_id|
            work = ActiveFedora::Base.search_by_id(child_id)
              work_type= work[:has_model_ssim].first.constantize
              parent_indexable_properties = work_type.properties.select{|index,val| val["index_to_parent"]||index=="language"||index=="contributor"?true:false}
              parent_indexable_properties.each do |prop, config|
                solr_doc["#{work_type.to_s.underscore}_#{prop}_ssim"] ||= []
                solr_doc["#{work_type.to_s.underscore}_#{prop}_ssim"] |= work[Solrizer.solr_name(prop)] if work[Solrizer.solr_name(prop)]
                solr_doc["#{prop}_ssim"] ||= []
                solr_doc["#{prop}_ssim"] |=  work[Solrizer.solr_name(prop)] if work[Solrizer.solr_name(prop)]
              end
          end
        end
        solr_doc
      end
  end
end
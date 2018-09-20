module InheritParentTitle
  extend ActiveSupport::Concern
  included do
    def title
      #Get parent title from solr document where title logic is defined

      solr_document = SolrDocument.new(find_parent_object_hash) unless find_parent_object_hash.nil?
      if(solr_document.title.any?)
        return [solr_document.title]
        []
      end
    end

    def find_parent_object_hash
      if @controller.params.has_key?(:parent_id)
        return ActiveFedora::Base.search_by_id(@controller.params[:parent_id])
      elsif model.in_objects.any?
        return model.in_objects.first.to_solr
      else
        return nil
      end
    end
  end
end

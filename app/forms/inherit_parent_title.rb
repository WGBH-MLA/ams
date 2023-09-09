module InheritParentTitle
  extend ActiveSupport::Concern
  included do
    def title
      #Get parent title from solr document where title logic is defined

      solr_document = case model
                      when ActiveFedora::Base
                        ::SolrDocument.new(find_parent_object_hash) unless find_parent_object_hash.nil?
                      when Valkyrie::Resource
                        # TODO: Bulkrax imports don't seem to have a controller so we're guarding for now
                        return nil unless @controller.present?

                        ::SolrDocument.find(@controller.params[:parent_id]) || (::SolrDocument.new(find_parent_object_hash) unless find_parent_object_hash.nil?)
                      end

      if(solr_document.title.any?)
        return [solr_document.title]
        []
      end
    end

    def find_parent_object_hash
      if @controller.params.has_key?(:parent_id)
        case model
        when ActiveFedora::Base
          return ActiveFedora::Base.search_by_id(@controller.params[:parent_id])
        when Valkyrie::Resource
          parent_resource = Hyrax.query_service.find_by(id: @controller.params[:parent_id])
          return Hyrax::ValkyrieIndexer.for(resource: parent_resource).to_solr
        end
      elsif model.try(:in_objects)&.any?
        return model.in_objects.first.to_solr
      else
        return nil
      end
    end
  end
end

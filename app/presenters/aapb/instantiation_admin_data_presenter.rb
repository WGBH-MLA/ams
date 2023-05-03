module AAPB
  module InstantiationAdminDataPresenter
    extend ActiveSupport::Concern
    included do
      def display_admin_data?
        !(aapb_preservation_lto.blank? &&
          aapb_preservation_disk.blank? &&
          md5.blank?
        )
      end

      def attribute_to_html(field, options = {})
        options.merge!({:html_dl=> true})

        solr_document = ::SolrDocument.find(id)
        work_class = solr_document["has_model_ssim"].first.constantize

        if attribute_indexed_to_parent?(field, work_class) && attribute_facetable?(field, work_class)
          # Use :symbol for field_name since all attributes indexed to parent are indexed as symbols.
          field_name = Solrizer.solr_name(field, :symbol)

          # Use parent SolrDocument to get value
          solr_document = ::SolrDocument.find(work_class.find(id).member_of.first.id) if work_class&.find(id)&.member_of&.present?

          return unless solr_document
          # Get values from sol_doc, should always be an Array since Assets can always have mutiple Instantiations
          values = solr_document[field_name] || Array.new
          return Hyrax::Renderers::IndexedToParentRenderer.new(field, values, options).render
        else
          return super(field, options)
        end
      end

    end
  end

end

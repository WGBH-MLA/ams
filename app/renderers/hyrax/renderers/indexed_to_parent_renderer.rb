module Hyrax
  module Renderers
    class IndexedToParentRenderer < Hyrax::Renderers::FacetedAttributeRenderer
      include SolrHelper
      def render
        markup = ''

        return markup if values.blank? && !options[:include_empty]

        markup << %(<dt>#{label}</dt>\n<dd><ul class='tabular'>)
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")

        values.each do |value|
          markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
        end
        markup << %(</ul></dd>)
        markup.html_safe
      end

      private

      def search_field
        ERB::Util.h(solr_name(options.fetch(:search_field, field), :symbol, type: :string))
      end
    end
  end
end
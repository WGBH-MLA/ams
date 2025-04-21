# frozen_string_literal: true
module Hyrax
  module Renderers
    class DrsimAttributeRenderer < AttributeRenderer
      private

      def li_value(value)
        link_to(ERB::Util.h(value), search_path(value))
      end

      def search_path(value)
        Rails.application.routes.url_helpers.search_catalog_path("after_date": value, "exact_or_range": "exact", locale: I18n.locale)
      end
    end
  end
end

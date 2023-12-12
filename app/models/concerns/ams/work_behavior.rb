module AMS
  module WorkBehavior
    extend ActiveSupport::Concern

    included do
      attribute :internal_resource, Valkyrie::Types::Any.default(self.name.gsub(/Resource$/,'').freeze), internal: true
      cattr_accessor :valid_child_concerns
    end

    class_methods do
      def _hyrax_default_name_class
        Hyrax::Name
      end

      def to_rdf_representation
        name.gsub("Resource", "")
      end
    end

    def members
      return @members if @members.present?
      @members = member_ids.map do |id|
        Hyrax.query_service.find_by(id: id)
      end
    end

    def to_solr
      Hyrax::ValkyrieIndexer.for(resource: self).to_solr
    end
  end
end

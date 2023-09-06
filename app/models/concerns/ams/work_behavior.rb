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
    end

    def members
      return @members if @members.present?
      @members = member_ids.map do |id|
        Hyrax.query_service.find_by(id: id)
      end
    end
  end
end

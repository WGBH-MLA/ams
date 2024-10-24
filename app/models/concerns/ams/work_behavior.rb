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
      @members ||= []
      member_id_vals = member_ids.map { |id| id.to_s }.to_set
      ids_from_members = @members.map { |m| m.id.to_s }
      # If the member_ids do not match the IDs within the members, then re-set the members to be an accurate reflection of the member IDs.
      # This allows us to modify resource.member_ids and have #members accurately reflect the changes.
      if (member_id_vals - ids_from_members).any?
        @members = member_ids.map do |id|
          begin
            Hyrax.query_service.find_by(id: id)
          rescue Valkyrie::Persistence::ObjectNotFoundError
            Rails.logger.warn("Could not find member #{id} for #{self.id}")
            # Return nil (to be removed with #compact below)
            nil
          end
        # Remove nils, all members must be able to respond to #members for recurisve member lookup.
        end.compact
      end
      @members
    end

    def to_solr
      Hyrax::ValkyrieIndexer.for(resource: self).to_solr
    end
  end
end

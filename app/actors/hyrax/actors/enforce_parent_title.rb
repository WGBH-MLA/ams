#custom actor check for parent_id param and force title to inherit from parent.
module Hyrax
  module Actors
    class EnforceParentTitle < Hyrax::Actors::BaseActor
      def create(env)
        inherit_parent_title(env)
        next_actor.create(env)
      end

      def update(env)
        inherit_parent_title(env)
        next_actor.update(env)
      end

      private
      def inherit_parent_title(env)
        if env.curation_concern.in_objects.any
          parent_object_hash = env.curation_concern.in_objects.first.to_solr
          solr_document = SolrDocument.new(parent_object_hash)
          env.attributes[:title] = Array(solr_document.title)
        end
      end

    end
  end
end

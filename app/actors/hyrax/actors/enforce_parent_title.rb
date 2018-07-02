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
        #TODO: find a way to query solr, that will speed this up
        if env.curation_concern.in_objects.any?
          env.attributes[:title] = Array(env.curation_concern.in_objects.first.title)
        end
      end

    end
  end
end

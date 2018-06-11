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
        if env.attributes.has_key?(:parent_id)
          parent_object = ActiveFedora::Base.find(env.attributes[:parent_id])
          if(parent_object.title.any?)
            env.attributes[:title] = [parent_object.title.first]
          end
          env.attributes.delete(:parent_id)
        end
      end

    end
  end
end

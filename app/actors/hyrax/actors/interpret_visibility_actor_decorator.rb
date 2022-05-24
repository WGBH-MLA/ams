# deal with fact that this class creates a brand new environment and does not pass
# any added arguments down to the new version. For importer flag compatibility

module Hyrax
  module Actors
    module InterpretVisibilityActorDecorator
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        intention = Hyrax::Actors::InterpretVisibilityActor::Intention.new(env.attributes)
        attributes = intention.sanitize_params
        new_env = Hyrax::Actors::Environment.new(env.curation_concern, env.current_ability, attributes, env.importing)
        validate(env, intention, attributes) && apply_visibility(new_env, intention) &&
          next_actor.create(new_env)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        intention = Hyrax::Actors::InterpretVisibilityActor::Intention.new(env.attributes)
        attributes = intention.sanitize_params
        new_env = Hyrax::Actors::Environment.new(env.curation_concern, env.current_ability, attributes, env.importing)
        validate(env, intention, attributes) && apply_visibility(new_env, intention) &&
          next_actor.update(new_env)
      end
    end
  end
end

::Hyrax::Actors::InterpretVisibilityActor.prepend(Hyrax::Actors::InterpretVisibilityActorDecorator)

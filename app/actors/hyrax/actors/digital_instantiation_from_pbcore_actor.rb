module Hyrax
  module Actors
    class DigitalInstantiationFromPBCoreActor < Hyrax::Actors::BaseActor
      def create(env)
        # require "pry"; binding.pry
        super && next_actor.create(env)
      end
    end
  end
end

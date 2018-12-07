require 'hyrax/actors/asset_from_pbcore_actor'
require 'hyrax/actors/digital_instantiation_from_pbcore_actor'

module Hyrax
  module Actors
    class BatchIngestActor < Hyrax::Actors::BaseActor

      attr_reader :env

      def create(env)
        @env = env
        batch_ingest_model_actor.create(env)
      end

      private

        def batch_ingest_model_actor
          batch_ingest_model_actor_class.new(next_actor)
        end

        def batch_ingest_model_actor_class
          case
          when env.attributes[:pbcore_description_document]
            Hyrax::Actors::AssetFromPBCoreActor
          when env.attributes[:pbcore_instantiation_document]
            Hyrax::Actors::DigitalInstantiationFromPBCoreActor
          else
            # TODO: Raise error here?
          end
        end
    end
  end
end

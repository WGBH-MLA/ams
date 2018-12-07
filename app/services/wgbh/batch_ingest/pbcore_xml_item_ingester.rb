require 'wgbh/batch_ingest/batch_item_ingester'
require 'hyrax/actors/batch_ingest_actor'

module WGBH
  module BatchIngest
    class PBCoreXMLItemIngester < WGBH::BatchIngest::BatchItemIngester

      def ingest
        actor.create(actor_env)
        curation_concern
      end

      private
        def actor
          @actor = actor_stack.build(Hyrax::Actors::Terminator.new)
        end

        def actor_stack
          @actor_stack ||= Hyrax::CurationConcern.actor_factory.dup.tap do |stack|
            stack.swap(Hyrax::Actors::ModelActor, Hyrax::Actors::BatchIngestActor)
          end
        end

        def actor_env
          @actor_env ||= Hyrax::Actors::Environment.new( curation_concern,
                                                         current_ability,
                                                         env_attributes )
        end

        def curation_concern
          @curation_concern ||= case
          when pbcore_description_document
            Asset.new
          when pbcore_instantiation_document
            DigitalInstantiation.new
          else
            # TODO: Raise error here?
          end
        end

        def current_ability
          @current_ability = Ability.new(submitter)
        end

        def pbcore
          @pbcore ||= pbcore_description_document || pbcore_instantiation_document
        end

        def pbcore_description_document
          if pbcore_xml =~ /pbcoreDescriptionDocument/
            @pbcore_description_document ||= PBCore::DescriptionDocument.new.parse(pbcore_xml)
          end
        end

        def pbcore_instantiation_document
          if pbcore_xml =~ /pbcoreInstantiationDocument/
            @pbcore_instantiation_document ||= PBCore::InstantiationDocument.new.parse(pbcore_xml)
          end
        end

        def pbcore_xml
          @pbcore_xml ||= File.read(@batch_item.source_location)
        end

        def env_attributes
          @env_attributes ||= {}.tap do |attrs|
            attrs[:pbcore_description_document] = pbcore_description_document if pbcore_description_document
            attrs[:pbcore_instantiation_document] = pbcore_instantiation_document if pbcore_instantiation_document
          end
        end
    end
  end
end

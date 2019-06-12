require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'
require 'aapb/batch_ingest/zipped_pbcore_digital_instantiation_mapper'

module AAPB
  module BatchIngest
    class PBCoreXMLItemIngester < AAPB::BatchIngest::BatchItemIngester
      def ingest
        if batch_item_is_asset?
          # This is a bit of a workaround. Errors will be raised from deep within
          # the stack if the user cannot be conveted to a Sipity::Entity.
          raise "Could not find or create Sipity Agent for user #{submitter}" unless sipity_agent

          batch_item_object = ingest_asset!

          # Raise validation errors as exceptions to be handled by the batch
          # item processing job in the hyrax-batch_ingest gem
          raise "Batch item contained invalid data.\n\n#{batch_item_object.errors.to_a.join("\n")}" if batch_item_object.errors.count > 0

          pbcore_digital_instantiations.each do |pbcore_digital_instantiation|
            di_batch_item = Hyrax::BatchIngest::BatchItem.create!(batch: batch_item.batch, status: 'initialized', id_within_batch: batch_item.id_within_batch)
            CoolDigitalJob.perform_later(parent_id: batch_item_object.id, xml: pbcore_digital_instantiation.to_xml, batch_item: di_batch_item)
          end

          pbcore_physical_instantiations.each do |pbcore_physical_instantiation|
            pi_batch_item = Hyrax::BatchIngest::BatchItem.create!(batch: batch_item.batch, status: 'initialized', id_within_batch: batch_item.id_within_batch)
            CoolPhysicalJob.perform_later(parent_id: batch_item_object.id, xml: pbcore_physical_instantiation.to_xml, batch_item: pi_batch_item)
          end
        elsif batch_item_is_digital_instantiation?
          batch_item_object = ingest_digital_instiation_and_manifest!
        else
          # TODO: More specific error?
          raise "PBCore XML ingest does not know how to ingest the given XML"
        end
        batch_item_object
      end

      # TODO: make private methods private again
      # private

        def batch_item_is_asset?
          pbcore_xml =~ /pbcoreDescriptionDocument/
        end

        def batch_item_is_digital_instantiation?
          pbcore_xml =~ /pbcoreInstantiationDocument/
        end

        def pbcore_digital_instantiations
          pbcore.instantiations.select { |inst| inst.digital }
        end

        def pbcore_physical_instantiations
          pbcore.instantiations.select { |inst| inst.physical }
        end

        def raise_ingest_errors(object)
          msg = "Error on #{object.class.model_name.human}: "
          unless object.errors.empty?
            msg += object.errors.messages.map { |field, msg| "#{field} #{msg.join(', ')}"}.join('; ')
          else
            msg += 'unknown error'
          end
          raise msg
        end

        def ingest_asset!
          asset = Asset.new
          actor = Hyrax::CurationConcern.actor
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(pbcore_xml).asset_attributes
          attrs[:hyrax_batch_ingest_batch_id] = batch_id
          env = Hyrax::Actors::Environment.new(asset, current_ability, attrs)
          raise_ingest_errors(asset) unless actor.create(env)
          asset
        end

        def ingest_digital_instiation_and_manifest!
          digital_instantiation = DigitalInstantiation.new
          digital_instantiation.skip_file_upload_validation = true
          actor = Hyrax::CurationConcern.actor
          mapper = AAPB::BatchIngest::ZippedPBCoreDigitalInstantiationMapper.new(@batch_item)
          attrs = mapper.digital_instantiation_attributes
          parent = mapper.parent_asset
          env = Hyrax::Actors::Environment.new(digital_instantiation, current_ability, attrs)
          raise_ingest_errors(digital_instantiation) unless actor.create(env)
          atomically_adopt parent, digital_instantiation
          digital_instantiation
        end

        def ingest_digital_instantiation!(parent:, xml:)
          digital_instantiation = DigitalInstantiation.new
          digital_instantiation.skip_file_upload_validation = true
          actor = Hyrax::CurationConcern.actor
          attrs = { pbcore_xml: xml }
          env = Hyrax::Actors::Environment.new(digital_instantiation, current_ability, attrs)
          env.attributes[:title] = ::SolrDocument.new(parent.to_solr).title
          raise_ingest_errors(digital_instantiation) unless actor.create(env)
          atomically_adopt parent, digital_instantiation
          digital_instantiation
        end

        def ingest_physical_instantiation!(parent:, xml:)
          physical_instantiation = PhysicalInstantiation.new
          actor = Hyrax::CurationConcern.actor
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(xml).physical_instantiation_attributes
          env = Hyrax::Actors::Environment.new(physical_instantiation, current_ability, attrs)
          env.attributes[:title] = ::SolrDocument.new(parent.to_solr).title
          raise_ingest_errors(physical_instantiation) unless actor.create(env)
          atomically_adopt parent, physical_instantiation
          physical_instantiation
        end

        def ingest_essence_track!(parent:, xml:)
          essence_track = EssenceTrack.new
          actor = Hyrax::CurationConcern.actor
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(xml).essence_track_attributes
          env = Hyrax::Actors::Environment.new(essence_track, current_ability, attrs)
          env.attributes[:title] = ::SolrDocument.new(parent.to_solr).title
          raise_ingest_errors(essence_track) unless actor.create(env)
          atomically_adopt parent, essence_track
          essence_track
        end

        def current_ability
          @current_ability = Ability.new(submitter)
        end

        def pbcore
          @pbcore ||= if batch_item_is_asset?
            PBCore::DescriptionDocument.parse(pbcore_xml)
          elsif batch_item_is_digital_instantiation?
            PBCore::InstantiationDocument.parse(pbcore_xml)
          else
            # TODO: Better error message here?
            raise "Unknown PBCore XML document type"
          end
        end

        def pbcore_xml
          @pbcore_xml ||= if @batch_item.source_data
            @batch_item.source_data
          elsif @batch_item.source_location
            File.read(@batch_item.source_location)
          else
            # TODO: Custom error
            raise "No source data or source location for BatchItem id=#{@batch_item.id}"
          end
        rescue => e
          raise e
        end

        # Returns a Sipity::Agent for the submitter User.
        # NOTE: Using PowerConverter is how Hyrax does it, so that's how we
        # do it here. This method was created because doing a batch ingest from
        # a new submitter was causing batch items to fail with
        # "Validation error: Agent must exist", due to trying to create a new
        # Sipity::Agent instance using a User instance from within multiple
        # concurrent threads; in one thread it succeeds, but in all other
        # concurrent threads it fails because the Agent cannot be retrieved nor
        # created. So we go ahead and just create it synchronously before hand
        # to avoid that issue.
        def sipity_agent
          PowerConverter.convert_to_sipity_agent(submitter)
        end

        # When running ingest methods concurrently in background jobs, we need
        # to add children to their parent objects atomically, so that jobs to
        # overwrite the children added from other concurrent jobs.
        # @param <ActiveFedora::Base> parent the parent object
        # @param <ActiveFedora::Base> child the child object
        def atomically_adopt(parent, child)
          # Get the lock for 10 seconds
          lock_manager.lock!("add_ordered_member_to:#{parent.id}", 120000) do |locked|
            parent.ordered_members << child
            parent.save!
          end
        rescue Redlock::LockError
          # redlock will automatically retry to acquire the lock according to
          # params passed to Redlock::Client.new (see #lock_manager). If all of
          # those retries fail, then we land here. Raise an exception that
          # indicates the failure as it is relevant to ingest.
          raise "Could not add #{child.class} (#{child.id}) to #{parent.class} (#{parent.id})."
        end

        def lock_manager
          @lock_manager ||= Redlock::Client.new(
            [ Redis.current ], {
            retry_count:   120,
            retry_delay:   5000, # every 5 seconds
            retry_jitter:  500,  # half a second
            redis_timeout: 0.1  # seconds
          })
        end
    end
  end
end

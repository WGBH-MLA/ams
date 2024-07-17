require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'
require 'aapb/batch_ingest/zipped_pbcore_digital_instantiation_mapper'
require 'aapb/batch_ingest/errors'

module AAPB
  module BatchIngest
    class PBCoreXMLItemIngester < AAPB::BatchIngest::BatchItemIngester
      def ingest
        if batch_item_is_asset?
          # Do not proceed unless submitter has proper permissions
          confirm_submitter_permissions!

          # This is a bit of a workaround. Errors will be raised from deep within
          # the stack if the user cannot be converted to a Sipity::Entity.
          raise "Could not find or create Sipity Agent for user #{submitter}" unless sipity_agent

          batch_item_object = ingest_asset!

          pbcore_digital_instantiations.each do |pbcore_digital_instantiation|
            di_batch_item = Hyrax::BatchIngest::BatchItem.create!(batch: batch_item.batch, status: 'initialized', id_within_batch: batch_item.id_within_batch)
            CoolDigitalJob.perform_later(parent_id: batch_item_object.id.to_s, xml: pbcore_digital_instantiation.to_xml, batch_item: di_batch_item)
          end

          pbcore_physical_instantiations.each do |pbcore_physical_instantiation|
            pi_batch_item = Hyrax::BatchIngest::BatchItem.create!(batch: batch_item.batch, status: 'initialized', id_within_batch: batch_item.id_within_batch)
            CoolPhysicalJob.perform_later(parent_id: batch_item_object.id.to_s, xml: pbcore_physical_instantiation.to_xml, batch_item: pi_batch_item)
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
        def validate_record_does_not_exist!(id)
          raise RecordExists.new(id) if ActiveFedora::Base.exists?(id: id)
        end

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

        def ingest_klass(klass, attrs)
          cx = Hyrax::Forms::ResourceForm.for(klass.new).prepopulate!
          cx.validate(attrs)

          result = Hyrax::Transactions::Container["work_resource.create_with_bulk_behavior"]
            .with_step_args(
              "work_resource.add_bulkrax_files" => {files: [], user: submitter},

              "change_set.set_user_as_depositor" => {user: submitter},
              "work_resource.change_depositor" => {user: submitter},
              'work_resource.save_acl' => { permissions_params: [attrs.try('visibility') || 'open'].compact }
            )
            .call(cx)

          if result.failure?
            msg = result.failure[0].to_s
            msg += " - #{result.failure[1].full_messages.join(',')}" if result.failure[1].respond_to?(:full_messages)
            raise StandardError, msg, result.trace
          end

          result.value!
        end

        def ingest_asset!
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(pbcore_xml).asset_attributes

          validate_record_does_not_exist! attrs[:id]
          attrs[:hyrax_batch_ingest_batch_id] = batch_id
          ingest_klass(AssetResource, attrs)
        end

        def ingest_digital_instiation_and_manifest!
          mapper = AAPB::BatchIngest::ZippedPBCoreDigitalInstantiationMapper.new(@batch_item)
          attrs = mapper.digital_instantiation_attributes
          parent = mapper.parent_asset
          digital_instantiation = ingest_klass(DigitalInstantiationResource, attrs)
          atomically_adopt parent, digital_instantiation
          digital_instantiation
        end

        def ingest_digital_instantiation!(parent:, xml:)
          attrs = { pbcore_xml: xml }
          attrs[:title] = ::SolrDocument.new(parent.to_solr).title
          digital_instantiation = ingest_klass(DigitalInstantiationResource, attrs)
          atomically_adopt parent, digital_instantiation
          digital_instantiation
        end

        def ingest_physical_instantiation!(parent:, xml:)
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(xml).physical_instantiation_resource_attributes
          attrs[:title] = ::SolrDocument.new(parent.to_solr).title
          physical_instantiation = ingest_klass(PhysicalInstantiationResource, attrs)
          atomically_adopt parent, physical_instantiation
          physical_instantiation
        end

        def ingest_essence_track!(parent:, xml:)
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(xml).essence_track_attributes
          attrs[:title] = ::SolrDocument.new(parent.to_solr).title
          essence_track = ingest_klass(EssenceTrackResource, attrs)
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
          Sipity.Agent(submitter)
        end

        # When running ingest methods concurrently in background jobs, we need
        # to add children to their parent objects atomically, so that jobs to
        # overwrite the children added from other concurrent jobs.
        # @param <ActiveFedora::Base> parent the parent object
        # @param <ActiveFedora::Base> child the child object
        def atomically_adopt(parent, child)
          # Get the lock for 10 seconds
          lock_manager.lock!("add_ordered_member_to:#{parent.id}", 120000) do |locked|
            parent.member_ids += [child.id.to_s]
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
            [ Hyrax.config.redis_connection ], {
            retry_count:   120,
            retry_delay:   5000, # every 5 seconds
            retry_jitter:  500,  # half a second
            redis_timeout: 0.1  # seconds
          })
        end

        def confirm_submitter_permissions!
          raise "User #{submitter} does not have permission to ingest this record" unless submitter_can_ingest?
        end

        def ability
          @ability ||= Ability.new(submitter)
        end

        def submitter_can_ingest?
          submitter_can_create_records? && submitter_can_update_admin_data?
        end

        def submitter_can_create_records?
          [
            AssetResource,
            DigitalInstantiationResource,
            PhysicalInstantiationResource,
            EssenceTrackResource,
            ContributionResource,
            AdminData,
            Hyrax::PcdmCollection
          ].all? do |klass|
            ability.can? :create, klass
          end
        end

        def submitter_can_update_admin_data?
          # If user can simply :update AdminData, return true.
          return true if ability.can? :update, AdminData

          # Otherwise, if use can update all these specific fiels, then return
          # true.
          [
            :update_sonyci_id,
            :update_hyrax_batch_ingest_batch_id,
            :update_last_pushed,
            :update_last_updated,
            :update_needs_update,
          ].all? do |action|
            ability.can? action, AdminData
          end
        end
    end
  end
end

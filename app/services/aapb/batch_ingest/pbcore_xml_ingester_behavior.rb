# AAPB::BatchIngest::PBCoreXMLItemIngesterBehavior
# This module is to DRY up common methods  between PBCoreXMLItemIngester and
# PBCoreXMLInstantiationReset, but also for any future custom ingester that
# needs to behave mostly like PBCoreXMLItemIngester.
module AAPB
  module BatchIngest
    module PBCoreXMLIngesterBehavior
      # Common private methods ingester classes.
      private

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
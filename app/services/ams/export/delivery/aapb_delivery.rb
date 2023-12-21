require 'ams/aapb_remote_ingester'

module AMS
  module Export
    module Delivery
      class AAPBDelivery < Base
        def deliver
          ingester.run!
          update_last_pushed
          notification_data[:remote_ingest_output] = ingester.output
        end

        private

          def ingester
            @ingester ||= AMS::AAPBRemoteIngester.new(
              filepath: export_results.filepath,
              host: ENV.fetch('AAPB_HOST'),
              ssh_key: ENV.fetch('AAPB_SSH_KEY')
            )
          end

          # Updates the :last_pushed field of the corresponding AdminData
          # records.
          # NOTE: Normally, we would look these up by
          #   GlobalID::Locator.locate_many, but apparently our GIDs are not
          #   correct, because it keeps trying to use "admindata" as the
          #   constant name instead of "AdminData". So we just parse the GID
          #   for the database ID here, which is not ideal.
          def update_last_pushed
            admin_data_ids = export_results.solr_documents.map do |solr_doc|
              Array.wrap(solr_doc['admin_data_gid_ssim']).first.sub('gid://ams/admindata/', '')
            end
            AdminData.where(id: admin_data_ids).update(last_pushed: Time.now)
          end
      end
    end
  end
end

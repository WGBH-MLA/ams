require 'ams/export/notification/base'
require 'ams/export/notification/push_to_aapb_notification'
require 'ams/export/notification/export_to_s3_notification'

module AMS
  module Export
    module Notification
      class << self
        def for_export_type(export_type)
          {
            push_to_aapb: PushToAAPBNotification,
            asset: ExportToS3Notification,
            physical_instantiation: ExportToS3Notification,
            digital_instantiation: ExportToS3Notification,
            pbcore_zip: ExportToS3Notification
          }.fetch(export_type.to_sym)
        end
      end
    end
  end
end

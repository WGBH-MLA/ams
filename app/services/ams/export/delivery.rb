require 'ams/export/delivery/base'
require 'ams/export/delivery/aapb_delivery'
require 'ams/export/delivery/s3_delivery'

module AMS
  module Export
    module Delivery
      def self.for_export_type(export_type)
        {
          'asset' => S3Delivery,
          'physical_instantiation' => S3Delivery,
          'digital_instantiation' => S3Delivery,
          'pbcore_zip' => S3Delivery,
          'push_to_aapb' => AAPBDelivery
        }.fetch(export_type)
      end
    end
  end
end

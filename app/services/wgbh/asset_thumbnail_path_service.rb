module WGBH
  class AssetThumbnailPathService < Hyrax::WorkThumbnailPathService
    class << self
      S3_THUMBNAIL_BASE = 'http://americanarchive.org.s3.amazonaws.com/thumbnail'.freeze
      class_attribute :object_type, :sonyci_id, :id, :aapb_digital_instantiation

      def call(object)
        self.object_type = object.class.name.underscore
        self.sonyci_id = object.admin_data.sonyci_id || []
        self.id = object.id
        self.aapb_digital_instantiation = object.digital_instantiations.find { |inst| inst.holding_organization.include?( "American Archive of Public Broadcasting") } || nil
        super
      end

      def default_image
        if !sonyci_id.empty? && !aapb_digital_instantiation.nil?
          if aapb_digital_instantiation.media_type.first == "Moving Image"
            ActionController::Base.helpers.image_path("#{S3_THUMBNAIL_BASE}/#{id}.jpg")
          elsif aapb_digital_instantiation.media_type.first == "Sound"
            ActionController::Base.helpers.image_path("/thumbs/AUDIO.png")
        else
          ActionController::Base.helpers.image_path "#{self.object_type}.png"
        end
      end
    end
  end
end

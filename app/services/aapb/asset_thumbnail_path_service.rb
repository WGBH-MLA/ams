module AAPB
  class AssetThumbnailPathService < Hyrax::WorkThumbnailPathService
    class << self
      S3_THUMBNAIL_BASE = 'http://americanarchive.org.s3.amazonaws.com/thumbnail'.freeze
      class_attribute :object_type, :sonyci_id, :id, :aapb_digital_instantiation, :digital_instantiations

      def call(object)
        self.object_type = object.class.name.underscore
        self.sonyci_id = object.admin_data.sonyci_id || []
        self.id = object.id
        self.digital_instantiations = object.digital_instantiations
        self.aapb_digital_instantiation = object.digital_instantiations.find { |inst| inst.holding_organization&.include?( "American Archive of Public Broadcasting") } || nil
        super
      end

      # This could be cleaned up.
      def default_image
        if !sonyci_id.empty? && !aapb_digital_instantiation.nil?
          if aapb_digital_instantiation.media_type.first == "Moving Image"
            ActionController::Base.helpers.image_path("#{S3_THUMBNAIL_BASE}/#{id}.jpg")
          elsif aapb_digital_instantiation.media_type.first == "Sound"
            ActionController::Base.helpers.image_path("/thumbs/AUDIO.png")
          else
            ActionController::Base.helpers.image_path "#{self.object_type}.png"
          end
        elsif sonyci_id.empty? && !aapb_digital_instantiation.nil?
          if aapb_digital_instantiation.media_type.first == "Moving Image"
            ActionController::Base.helpers.image_path("/thumbs/VIDEO_NOT_DIG.png")
          elsif aapb_digital_instantiation.media_type.first == "Sound"
            ActionController::Base.helpers.image_path("/thumbs/AUDIO_NOT_DIG.png")
          else
            ActionController::Base.helpers.image_path "#{self.object_type}.png"
          end
        elsif sonyci_id.empty? && aapb_digital_instantiation.nil?
          if !digital_instantiations.empty?
            if digital_instantiations.first.media_type.first == "Moving Image"
              ActionController::Base.helpers.image_path("/thumbs/VIDEO_NOT_DIG.png")
            elsif digital_instantiations.first.media_type.first == "Sound"
              ActionController::Base.helpers.image_path("/thumbs/AUDIO_NOT_DIG.png")
            else
              ActionController::Base.helpers.image_path "#{self.object_type}.png"
            end
          else
            ActionController::Base.helpers.image_path "#{self.object_type}.png"
          end
        else
          ActionController::Base.helpers.image_path "#{self.object_type}.png"
        end
      end
    end
  end
end

module AAPB
  class AssetThumbnailPathService < Hyrax::WorkThumbnailPathService

    S3_THUMBNAIL_BASE = 'http://americanarchive.org.s3.amazonaws.com/thumbnail'.freeze

    class << self
      attr_accessor :object_type, :sonyci_id, :id, :aapb_digital_instantiation, :digital_instantiations

      def call(object)
        @object_type = object.class.name.underscore
        @sonyci_id = object.admin_data&.sonyci_id || []
        @id = object.id
        case object
        when ActiveFedora::Base
          @digital_instantiations = object.digital_instantiations
          @aapb_digital_instantiation = object.digital_instantiations.find { |inst| inst.holding_organization&.include?( "American Archive of Public Broadcasting") } || nil
        when Valkyrie::Resource
          @digital_instantiations = object.digital_instantiation_resources
          @aapb_digital_instantiation = object.digital_instantiation_resources.find { |inst| inst.holding_organization&.include?( "American Archive of Public Broadcasting") } || nil
        end
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

module WGBH
  class WorkThumbnailPathService < Hyrax::WorkThumbnailPathService
    class << self
      class_attribute :object_type
      def call(object)
        self.object_type = object.class.name.underscore
        super
      end

      def default_image
        ActionController::Base.helpers.image_path "#{self.object_type}.png"
      end
    end
  end
end

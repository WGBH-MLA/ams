module AAPB
  class WorkThumbnailPathService < Hyrax::WorkThumbnailPathService
    class_attribute :object_type

    def self.call(object)
      self.object_type = object.class.name.underscore
      super(object)
    end

    def self.default_image
      ActionController::Base.helpers.image_path "#{self.object_type}.png"
    end
  end
end

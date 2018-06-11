module WGBH
  class MetadataService < Hyrax::FormMetadataService
    def self.multiple?(model_class, field)
      if [:title].include?(field.to_sym)
        false
      else
        super
      end
    end
  end
end
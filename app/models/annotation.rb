class Annotation < ApplicationRecord
  belongs_to :admin_data

  validates :annotation_type, :presence => true
  validate :annotation_type_registered
  validates :value, :presence => true
  validates :ref, presence: true, if: :supplemental_material?

  def annotation_type_registered
    return true if AnnotationTypesService.new.select_all_options.to_h.values.include?(annotation_type)
    raise "annotation_type not registered with the AnnotationTypesService: #{annotation_type}."
  end

  def supplemental_material?
    annotation_type == "supplemental_material" ? true : false
  end

  # Downcasing for normalization
  def self.registered_annotation_types
    AnnotationTypesService.new.select_all_options.to_h.transform_keys(&:downcase)
  end

  def self.find_annotation_type_id(type_name)
    registered_annotation_types[type_name.to_s.downcase]
  end

  def self.ingestable_attributes
    Annotation.registered_annotation_types.values
  end

end

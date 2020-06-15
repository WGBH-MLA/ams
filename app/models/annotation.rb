class Annotation < ApplicationRecord
  belongs_to :admin_data

  validates :annotation_type, :presence => true
  validates :value, :presence => true

  validates :ref, presence: true, if: :supplemental_material?

  def supplemental_material?
    return true if annotation_type == "Supplemental Material"
    false
  end
end

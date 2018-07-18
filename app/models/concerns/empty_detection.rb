module EmptyDetection
  extend ActiveSupport::Concern

  included do
  def empty?
    attributes.all? do |k, v|
      ['id', 'inspection_id', 'created_at', 'updated_at'].include?(k) || v.nil? || v == [] || v == [""]
    end
  end
  end
end

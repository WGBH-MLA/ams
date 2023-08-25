# frozen_literal: true

Bulkrax::ApplicationParser.class_eval do
  def parents
    @parents ||= setup_parents
  end

  def setup_parents
    pts = []
    records.each do |record|
      r = if record.respond_to?(:to_h)
            record.to_h
          else
            record
          end
      next unless r.is_a?(Hash)
      children = if r[:children].is_a?(String)
                   r[:children].split(/\s*[:;|]\s*/)
                 else
                   r[:children]
                 end
      next if children.blank?
      pts << {
        r[source_identifier] => children
      }
    end
    pts.blank? ? pts : pts.inject(:merge)
  end
end
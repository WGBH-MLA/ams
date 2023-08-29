# frozen_literal: true

# OVERRIDE Bulkrax 5.3.0 to adopt Bulkrax 1.0.2 implementation
# keeping this code allows us to continue use custom relationships for GBH

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

    # Optional, only used by certain parsers
    # Other parsers should override with a custom or empty method
    # Will be skipped unless the #record is a Hash
    def create_parent_child_relationships
      parents.each do |key, value|
        parent = entry_class.where(
          identifier: key,
          importerexporter_id: importerexporter.id,
          importerexporter_type: 'Bulkrax::Importer'
        ).first

        # not finding the entries here indicates that the given identifiers are incorrect
        # in that case we should log that
        children = value.map do |child|
          entry_class.where(
            identifier: child,
            importerexporter_id: importerexporter.id,
            importerexporter_type: 'Bulkrax::Importer'
          ).first
        end.compact.uniq

        if parent.present? && (children.length != value.length)
          # Increment the failures for the number we couldn't find
          # Because all of our entries have been created by now, if we can't find them, the data is wrong
          Rails.logger.error("Expected #{value.length} children for parent entry #{parent.id}, found #{children.length}")
          break if children.empty?
          Rails.logger.warn("Adding #{children.length} children to parent entry #{parent.id} (expected #{value.length})")
        end
        parent_id = parent.id
        child_entry_ids = children.map(&:id)
        ChildRelationshipsJob.perform_later(parent_id: parent_id, child_entry_ids: child_entry_ids, importer_run_id: current_run.id)
      end
    rescue StandardError => e
      status_info(e)
    end
end
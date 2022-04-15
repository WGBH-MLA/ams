# frozen_string_literal: true

# adds importer to allow index queueing

require_dependency Bulkrax::Engine.root.join('app', 'models', 'concerns', 'bulkrax', 'import_behavior')

Bulkrax::ImportBehavior.class_eval do
  def factory
    @factory ||= Bulkrax::ObjectFactory.new(attributes: self.parsed_metadata || self.raw_metadata,
                                            source_identifier_value: identifier,
                                            work_identifier: parser.work_identifier,
                                            collection_field_mapping: parser.collection_field_mapping,
                                            replace_files: replace_files,
                                            user: user,
                                            klass: factory_class,
                                            update_files: update_files,
                                            importer: self.importer
                                           )
  end
end

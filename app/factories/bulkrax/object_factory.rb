# frozen_string_literal: true

require_dependency Bulkrax::Engine.root.join('app', 'factories', 'bulkrax', 'object_factory')

Bulkrax::ObjectFactory.class_eval do 
  def search_by_identifier
    query = { "#{work_identifier}_sim" =>
              source_identifier_value }
    # Query can return partial matches (something6 matches both something6 and something68)
    # so we need to weed out any that are not the correct full match. But other items might be
    # in the multivalued field, so we have to go through them one at a time.
    match = klass.where(query).detect { |m| m.send(work_identifier).include?(source_identifier_value) }
    return match if match
  end
end

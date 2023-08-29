# OVERRIDE BULKRAX 1.0.2 to avoid ActiveTriples::Relation::ValueError
require_dependency Bulkrax::Engine.root.join('app', 'models', 'concerns', 'bulkrax', 'has_matchers')

Bulkrax::HasMatchers.class_eval do     # rubocop:disable Metrics/ParameterLists
  def add_metadata(node_name, node_content, index = nil)
    field_to(node_name).each do |name|
      matcher = self.class.matcher(name, mapping[name].symbolize_keys) if mapping[name] # the field matched to a pre parsed value in application_matcher.rb
      object_name = get_object_name(name) || false # the "key" of an object property. e.g. { object_name: { alpha: 'beta' } }
      multiple = multiple?(name) # the property has multiple values. e.g. 'letters': ['a', 'b', 'c']
      object_multiple = object_name && multiple?(object_name) # the property's value is an array of object(s)

      next unless field_supported?(name) || (object_name && field_supported?(object_name))

      if object_name
        Rails.logger.info("Bulkrax Column automatically matched object #{node_name}, #{node_content}")
        parsed_metadata[object_name] ||= object_multiple ? [{}] : {}
      end

      value = if matcher
                result = matcher.result(self, node_content)
                matched_metadata(multiple, name, result, object_multiple)
              elsif multiple
                Rails.logger.info("Bulkrax Column automatically matched #{node_name}, #{node_content}")
                # OVERRIDE BULKRAX 1.0.2 to avoid ActiveTriples::Relation::ValueError
                multiple_metadata(node_content, node_name)
              else
                Rails.logger.info("Bulkrax Column automatically matched #{node_name}, #{node_content}")
                single_metadata(node_content)
              end

      if App.rails_5_1?
        set_parsed_data(object_multiple, object_name, name, index, value)
      else
        object_name.present? ? set_parsed_object_data(object_multiple, object_name, name, index, value) : set_parsed_data(name, value)
      end
    end
  end

  def multiple_metadata(content, name = nil)
    return unless content

    case content
    when Nokogiri::XML::NodeSet
      content&.content
    when Array
      # OVERRIDE BULKRAX 1.0.2 to avoid ActiveTriples::Relation::ValueError
      if name == 'head' || name == 'tail'
        content.map do |obj|
          obj.delete("id")
        end
      else
        content
      end
    when Hash
      Array.wrap(content)
    when String
      Array.wrap(content.strip)
    else
      Array.wrap(content)
    end
  end
end

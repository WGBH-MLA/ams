# frozen_string_literal: true
# rubocop:disable Metrics/ModuleLength
module HasAmsMatchers
  extend ActiveSupport::Concern
  ##
  # Field of the model that can be supported
  def field_supported?(field)
    field = field.gsub("_attributes", "")

    return false if excluded?(field)
    return true if supported_bulkrax_fields.include?(field)
    # title is not defined in M3
    return true if field == "title"
    return true if field == "description"
    return true if field == "subject"
    return true if field == "contributors"

    property_defined = factory_class.singleton_methods.include?(:properties) && factory_class.properties[field].present?

    factory_class.method_defined?(field) && (Bulkrax::ValkyrieObjectFactory.schema_properties(factory_class).include?(field) || property_defined)
  end

  ##
  # Determine a multiple properties field
  def multiple?(field)
    @multiple_bulkrax_fields ||=
      %W[
        file
        remote_files
        rights_statement
            #{related_parents_parsed_mapping}
            #{related_children_parsed_mapping}
      ]

    return true if @multiple_bulkrax_fields.include?(field)
    return false if field == "model"
    # title is not defined in M3
    return true if field == "title"
    return true if field == "description"
    return true if field == "subject"

    field_supported?(field) && (multiple_field?(field) || factory_class.singleton_methods.include?(:properties) && factory_class&.properties&.[](field)&.[]("multiple"))
  end

  def multiple_field?(field)
    form_definition = schema_form_definitions[field.to_sym]
    form_definition.nil? ? false : form_definition[:multiple]
  end

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

      object_name.present? ? set_parsed_object_data(object_multiple, object_name, name, index, value) : set_parsed_data(name, value)
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

  # override: we want to directly infer from a property being multiple that we should split when it's a String
  # def multiple_metadata(content)
  #   return unless content

  #   case content
  #   when Nokogiri::XML::NodeSet
  #     content&.content
  #   when Array
  #     content
  #   when Hash
  #     Array.wrap(content)
  #   when String
  #     String(content).strip.split(Bulkrax.multi_value_element_split_on)
  #   else
  #     Array.wrap(content)
  #   end
  # end

  def schema_form_definitions
    @schema_form_definitions ||= Hyrax::SimpleSchemaLoader.new.form_definitions_for(schema: factory_class.name.underscore.to_sym)
  end
end

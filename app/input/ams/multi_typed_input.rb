module AMS
  class MultiTypedInput < MultiValueInput

    def build_field(value, _index)

      input_options = text_input_html_options(value[1], _index)
      select_options = select_input_html_options(_index)
      output = "";
      if input_options.delete(:type) == 'textarea'
        output = @builder.text_area("#{fields_prefix}_value", input_options )
      else
        output = @builder.text_field("#{fields_prefix}_value", input_options)
      end
      output += @builder.select("#{fields_prefix}_type", type_choices, { selected: value[0] }, select_options)
      output
    end

    def type_choices
      raise NotImplementedError, "A MultiTypedInput must have type choices"
    end

    def fields_prefix
      raise NotImplementedError, "A MultiTypedInput must have fields_prefix"
    end

    def input_css_classes
      ["multi-text-field", "multi_value"]
    end

    def select_css_classes
      []
    end

    def text_input_html_options(value,index)
      options = input_html_options.dup.merge(
        name: "#{@builder.object_name}[#{attribute_name}][][value]",
        value: value,
        id: input_dom_id_prefix + "#{index}_input",
        autocomplete:"off"
      )

      options[:class] |= input_css_classes

      if options[:value].blank?
        options.delete(:required)
        options[:class].delete(:required)
      else
        options[:class] << :required
      end
      options
    end

    def select_input_html_options(index)
      options = input_html_options.dup.merge(
        name: "#{@builder.object_name}[#{attribute_name}][][type]",
        id: input_dom_id_prefix + "#{index}_type"
      )

      # Do not set the 'type' select to required, since blank option is allowed.
      # But 'value' needs to remain required if set.
      options.delete(:required)
      options[:class].delete(:required)
      options[:class] |= select_css_classes
      options
    end

    def input_dom_id_prefix
      "#{object_name}_#{attribute_name}_"
    end
  end
end

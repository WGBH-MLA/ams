class MultipleDescriptionsWithTypesInput < MultiValueInput

  def build_field(value, index)
    description_type_choices = DescriptionTypesService.select_all_options

    select_input_html_options = input_html_options.merge({
      name: "#{@builder.object_name}[description_type][]"
    })

    text_input_html_options = input_html_options.merge({
      name: "#{@builder.object_name}[description_value][]",
      value: value[1]
    })

    # Do not set the 'description_type' select to required, since blank option is allowed.
    # But 'description_value' needs to remain required if set.
    select_input_html_options.delete(:required)
    select_input_html_options[:class].delete(:required)
    text_input_html_options[:class] << "multi-text-field"

    if(text_input_html_options[:title_value].blank?)
      if(@rendered_first_element)
        text_input_html_options.delete(:required)
        text_input_html_options[:class].delete(:required)
      end
      @rendered_first_element = true
    end

    output = @builder.text_area(:description_value, text_input_html_options)
    output += @builder.select(:description_type, description_type_choices, { selected: value[0] }, select_input_html_options)
    output
  end
end

class MultipleDescriptionsWithTypesInput < MultiValueInput

  def build_field(value, index)
    description_type_choices = TitleAndDescriptionTypesService.select_all_options

    select_input_html_options = input_html_options.merge({
      name: "#{@builder.object_name}[description_type][]"
    })

    text_input_html_options = input_html_options.merge({
      name: "#{@builder.object_name}[description_value][]",
      value: value[1]
    })

    output = @builder.text_area(:description_value, text_input_html_options)
    output += @builder.select(:description_type, description_type_choices, { selected: value[0] }, select_input_html_options)
    output
  end
end

class MultipleDatesWithTypesInput < MultiValueInput

  def build_field(value, index)
    date_types_service = DateTypesService.new
    date_type_choices = date_types_service.select_all_options

    select_input_html_options = input_html_options.dup.merge({
      name: "#{@builder.object_name}[date_type][]"
    })

    date_input_html_options = input_html_options.dup.merge({
      name: "#{@builder.object_name}[date_value][]",
      value: value[1]
    })

    output = @builder.date_field(:date_value, date_input_html_options)
    output += @builder.select(:date_type, date_type_choices, { selected: value[0] }, select_input_html_options)
    output
  end
end

class MultipleDatesWithTypesInput < MultiValueInput

  def build_field(value, index)
    date_types_service = DateTypesService.new
    date_type_choices = date_types_service.select_all_options

    input_dom_id_prefix = "#{object_name}_#{attribute_name}_#{index}"

    select_input_html_options = input_html_options.dup.merge({
      name: "#{@builder.object_name}[date_type][]",
      id: input_dom_id_prefix + "_type"
    })

    date_input_html_options = input_html_options.dup.merge({
      name: "#{@builder.object_name}[date_value][]",
      value: value[1],
      autocomplete:"off",
      id: input_dom_id_prefix + "_input"
    })

    date_input_html_options[:class] += ["datepicker","multi_value","multi-text-field"]
    date_input_html_options[:pattern] = AMS::NonExactDateService.regex.to_s

    output = @builder.text_field(:date_value, date_input_html_options)
    output += @builder.select(:date_type, date_type_choices, { selected: value[0] }, select_input_html_options)
    output
  end
end

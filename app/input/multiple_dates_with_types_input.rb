class MultipleDatesWithTypesInput < MultiValueInput

  def build_field(value, index)
    date_types_service = DateTypesService.new
    date_type_choices = date_types_service.select_all_options

    select_input_html_options = input_html_options.merge({
      name: "#{@builder.object_name}[date_type][]"
    })

    date_input_html_options = input_html_options.merge({
      name: "#{@builder.object_name}[date_value][]",
      value: value[1]
    })

    output = @builder.date_field(:date_value, date_input_html_options)
    output += @builder.select(:date_type, date_type_choices, { selected: value[0] }, select_input_html_options)
    output
  end


  # Overrides MultiValueInput#collection from Hydra-editor. The original
  # method calls object[attribute_name] instead of object.send(attribute_name)
  # to retrieve the value. By using the square brackets, it bypasses any
  # accessor method on the form object that you may have created to decorate
  # the values, which is exactly what we are doing.
  # TODO: Remove this method after https://github.com/samvera/hydra-editor/pull/153
  #  is merged.
  def collection
    @collection ||= begin
      # As of this writing, the line below is the only one changed from the
      # original.
      val = object.send(attribute_name)
      col = val.respond_to?(:to_ary) ? val.to_ary : val
      col.reject { |value| value.to_s.strip.blank? } + ['']
    end
  end
end

class MultipleDateInput < MultiValueInput
  def build_field(value, index)
    options = build_field_options(value, index)
    options[:pattern] = AMS::NonExactDateService.regex_string
    options[:class] += ["datepicker","multi_value","multi-text-field"]

    @builder.text_field(attribute_name, options)
  end
end

class MultipleDatesWithTypesInput < AMS::MultiTypedInput

  def text_input_html_options(value, index)
    options = super
    options[:pattern] = AMS::NonExactDateService.regex.to_s
    options
  end

  def type_choices
    date_types_service = DateTypesService.new
    choices = date_types_service.select_all_options
  end

  def fields_prefix
    "date"
  end

  def input_css_classes
    css_classes = super
    css_classes << "datepicker"
  end
end

class MultipleDatesWithTypesInput < AMS::MultiTypedInput

  def text_input_html_options(value, index)
    super.merge( { pattern: AMS::NonExactDateService.regex.to_s } )
  end

  def type_choices
    DateTypesService.new.select_all_options
  end

  def fields_prefix
    "date"
  end

  def input_css_classes
    super << "datepicker"
  end
end

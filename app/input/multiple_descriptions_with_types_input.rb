class MultipleDescriptionsWithTypesInput < AMS::MultiTypedInput

  def type_choices
    description_type_choices = DescriptionTypesService.new
    choices = description_type_choices.select_all_options
  end

  def fields_prefix
    "description"
  end

  def text_input_html_options(value, index)
    options = super
    options[:type] = "textarea"
    options
  end


end

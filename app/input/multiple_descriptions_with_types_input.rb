class MultipleDescriptionsWithTypesInput < AMS::MultiTypedInput

  def type_choices
    DescriptionTypesService.new.select_all_options
  end

  def fields_prefix
    "description"
  end

  def text_input_html_options(value, index)
    super.merge( { type: "textarea" } )
  end


end

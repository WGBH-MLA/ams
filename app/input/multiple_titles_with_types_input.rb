class MultipleTitlesWithTypesInput < AMS::MultiTypedInput

  def type_choices
    title_typed_service = TitleTypesService.new
    title_type_choices = title_typed_service.select_all_options
  end

  def fields_prefix
    "title"
  end
end

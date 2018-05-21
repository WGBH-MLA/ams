class MultipleTitlesWithTypesInput < MultiValueInput

  def build_field(value, index)
    # TODO: this data needs to come from a controlled vocab of title types
    # rather than being hardcoded here.
    title_type_choices = TitleAndDescriptionTypesService.select_all_options

    select_input_html_options = input_html_options.dup.merge({
      name: "#{@builder.object_name}[title_type][]"
    })

    text_input_html_options = input_html_options.dup.merge({
      name: "#{@builder.object_name}[title_value][]",
      value: value[1]
    })

    # Do not set the 'title_type' select to required, since blank option is allowed.
    # But 'title_value' needs to remain required if set.
    select_input_html_options.delete(:required)
    select_input_html_options[:class].delete(:required)

    output = @builder.text_field(:title_value, text_input_html_options)
    output += @builder.select(:title_type, title_type_choices, { selected: value[0] }, select_input_html_options)
    output
  end
end

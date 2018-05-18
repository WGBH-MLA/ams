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


  # Overrides MultiValueInput#collection from Hydra-editor. The original
  # method calls object[attribute_name] instead of object.send(attribute_name)
  # to retrieve the value. By using the square brackets, it bypasses any
  # accessor method on the form object that you may have created to decorate
  # the values, which is exactly what we are doing.
  # TODO: Create a PR for hydra-editor to change `object[attribute_name]` to
  # `object.send(attribute_name)` in MultiValueInput#collection.
  def collection
    @collection ||= begin
      # As of this writing, the line below is the only once changed from the
      # original.
      val = object.send(attribute_name)
      col = val.respond_to?(:to_ary) ? val.to_ary : val
      col.reject { |value| value.to_s.strip.blank? } + ['']
    end
  end
end

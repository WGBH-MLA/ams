class ChildAnnotationsInput < MultiValueInput
  def build_field(value, index)

    annotation_types_service = AnnotationTypesService.new
    type_choices = [""] + annotation_types_service.select_all_options

    input_dom_id_prefix = "#{object_name}_#{attribute_name}_#{index}"

    id_hidden_options = input_html_options.dup.merge(
        value: value[0],
        name: "#{@builder.object_name}[annotations][][id]",
        id: input_dom_id_prefix + "_id"
    )

    admin_id_hidden_options = input_html_options.dup.merge(
        value: value[1],
        name: "#{@builder.object_name}[annotations][][admin_data_id]",
        id: input_dom_id_prefix + "_admin_data_id"
    )

    type_select_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[annotations][][annotation_type]",
      id: input_dom_id_prefix + "_annotation_type"
    )

    ref_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[annotations][][ref]",
      value: value[3],
      placeholder: "ref",
      id: input_dom_id_prefix + "_ref"
    )

    source_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[annotations][][source]",
      value: value[4],
      placeholder: "Source",
      id: input_dom_id_prefix + "_source"
    )

    value_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[annotations][][value]",
      value: value[5],
      placeholder: "Value",
      id: input_dom_id_prefix + "_value"
    )

    annotation_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[annotations][][annotation]",
      value: value[6],
      placeholder: "Annotation",
      id: input_dom_id_prefix + "_annotation"
    )

    version_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[annotations][][version]",
      value: value[7],
      placeholder: "Version",
      id: input_dom_id_prefix + "_version"
    )

    # Do not set the 'title_type' select to required, since blank option is allowed.
    # But 'title_value' needs to remain required if set.
    type_select_input_html_options.delete(:required)
    type_select_input_html_options[:class].delete(:required)
    ref_text_input_html_options.delete(:required)
    ref_text_input_html_options[:class].delete(:required)
    source_text_input_html_options.delete(:required)
    source_text_input_html_options[:class].delete(:required)
    annotation_text_input_html_options.delete(:required)
    annotation_text_input_html_options[:class].delete(:required)
    version_text_input_html_options.delete(:required)
    version_text_input_html_options[:class].delete(:required)

    output = @builder.hidden_field(:annotation_id, id_hidden_options)
    output += @builder.hidden_field(:admin_data_id, admin_id_hidden_options)
    output += @builder.select(:annotation_type, type_choices, { selected: value[2] }, type_select_input_html_options)
    output += @builder.text_field(:ref, ref_text_input_html_options)
    output += @builder.text_field(:source, source_text_input_html_options)
    output += @builder.text_field(:value, value_text_input_html_options)
    output += @builder.text_field(:annotation, annotation_text_input_html_options)
    output += @builder.text_field(:version, version_text_input_html_options)
    output
  end
end

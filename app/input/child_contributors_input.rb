class ChildContributorsInput < MultiValueInput

  # Returns the HTML for the input field, including the hidden field for the contributor ID,
  # The #build_field method comes from MultiValueInput class which is defined in hydra-editor gem used by Hyrax.
  # That object in turn inherits from SimpleForm::Inputs::CollectionInput.
  # See https://github.com/samvera/hydra-editor/blob/v6.2.0/app/inputs/multi_value_input.rb
  def build_field(value, _index)
    [
      contributor_id_hidden_field(value: value[0]),
      contributor_field_group(
        role_input_fields(
          contributor_role_value: value[1],
          contributor_name_value: value[2],
          contributor_role_annotation_value: value[3]
        )
      ),
      contributor_field_group(
        affiliation_fields(
          affiliation_value: value[4],
          affiliation_annotation_value: value[5]
        )
      ),
      contributor_field_group(
        portrayal_and_annotation_fields(
          portrayal_value: value[6],
          annotation_value: value[7]
        )
      ),
      contributor_field_group(
        time_fields(
          start_time_value: value[8],
          end_time_value: value[9],
          time_annotation_value: value[10]
      )
    )
    ].join.html_safe
  end

  # Returns the role, name, and role annotation fields as a group.
  def role_input_fields(contributor_role_value:, contributor_name_value:, contributor_role_annotation_value:)
    name_requied = 
    [
      role_select_field(value: contributor_role_value),
      # The Contibutor name is required if a role is selected (!! the value to a boolean).
      contributor_name_field(value: contributor_name_value, required: !!contributor_role_value),
      contributor_role_annotation_field(value: contributor_role_annotation_value)
    ]
  end

  # Returns the affiliation and affiliation annotation fields as a group.
  def affiliation_fields(affiliation_value:, affiliation_annotation_value:)
    [
      affiliation_field(value: affiliation_value),
      affiliation_annotation_field(value: affiliation_annotation_value)
    ]
  end

  # Returns the portrayal and annotation fields as a group.
  def portrayal_and_annotation_fields(portrayal_value:, annotation_value:)
    [
      portrayal_field(value: portrayal_value),
      annotation_field(value: annotation_value)
    ]
  end

  # Returns the start time, end time, and time annotation fields as a group.
  def time_fields(start_time_value:, end_time_value:, time_annotation_value:)
    [
      start_time_field(value: start_time_value),
      end_time_field(value: end_time_value),
      time_annotation_field(value: time_annotation_value)
    ]
  end

  def contributor_id_hidden_field(value:)
    @builder.hidden_field(
      :contributor_id,
      hidden_input_options(
        id: "contributor_id",
        name: "id",
        value: value
      )
    )
  end

  # Returns the role select field with the given value. The options for the select
  def role_select_field(value: nil, required: false)
    @builder.select(
      :contributor_role,
      role_choices, { selected: value },
      select_input_options(
        id: "contributor_role",
        name: "contributor_role",
        # Does this need to here if selected above?
        value: value,
        required: required
      )
    )
  end

  # Returns a list of contributor role choices, with a blank option at the top.
  def role_choices
    contributor_role_service = ContributorRoleService.new
    [""] + contributor_role_service.select_all_options
  end

  # Returns the contributor name text field.
  def contributor_name_field(value: nil, required: false)
    @builder.text_field(
      :contributor_name,
      text_input_options(
        # NOTE: We refer to contributor_name in this file for clarity, but the
        # HTML field for the contributor name is actually just called
        # 'contributor' from the PBCore element <contributor> and needs to stay
        # 'contributor' to work with downstream code that is expecting that name,
        # namely AssetResourceForm (see app/forms/asset_resource_form.rb)
        id: "contributor",
        name: "contributor",
        value: value,
        placeholder: "Name"
      )
    )
  end

  # Returns the contributor role annotation text field.
  def contributor_role_annotation_field(value: nil, required: false)
    @builder.text_field(
      :contributor_role_annotation,
      text_input_options(
        id: "contributor_role_annotation",
        name: "contributor_role_annotation",
        value: value,
        placeholder: "Role Annotation"
      )
    )
  end

  # Returns the affiliation text field.
  def affiliation_field(value: nil, required: false)
    @builder.text_field(
      :affiliation,
      text_input_options(
        id: "affiliation",
        name: "affiliation",
        value: value,
        placeholder: "Affiliation"
      )
    )
  end

  # Returns the affiliation annotation text field.
  def affiliation_annotation_field(value: nil, required: false)
    @builder.text_field(
      :affiliation_annotation,
      text_input_options(
        id: "affiliation_annotation",
        name: "affiliation_annotation",
        value: value,
        placeholder: "Affiliation Annotation"
      )
    )
  end

  # Returns the portrayal text field.
  def portrayal_field(value: nil, required: false)
    @builder.text_field(
      :portrayal,
      text_input_options(
        id: "portrayal",
        name: "portrayal",
        value: value,
        placeholder: "Portrayal"
      )
    )
  end

  # Returns the annotation text field.
  def annotation_field(value: nil, required: false)
    @builder.text_field(
      :annotation,
      text_input_options(
        id: "annotation",
        name: "annotation",
        value: value,
        placeholder: "Annotation"
      )
    )
  end

  # Returns the start time text field.
  def start_time_field(value: nil, required: false)
    @builder.text_field(
      :start_time,
      text_input_options(
        id: "start_time",
        name: "start_time",
        value: value,
        placeholder: "Start Time"
      )
    )
  end

  # Returns the end time text field.
  def end_time_field(value: nil, required: false)
    @builder.text_field(
      :end_time,
      text_input_options(
        id: "end_time",
        name: "end_time",
        value: value,
        placeholder: "End Time"
      )
    )
  end

  # Returns the time annotation text field.
  def time_annotation_field(value: nil, required: false)
    @builder.text_field(
      :time_annotation,
      text_input_options(
        id: "time_annotation",
        name: "time_annotation",
        value: value,
        placeholder: "Time Annotation",
        long: true
      )
    )
  end
      

  # Returns a hash of options for a hidden input field, including the name, value,
  # placeholder, class, and id.
  def hidden_input_options(id:, name:, value: nil)
    input_html_options.merge(
      name: "#{@builder.object_name}[contributors][][#{name}]",
      value: value,
      placeholder: placeholder,
      class: css_classes,
      id: id_with_prefix(id)
      )
  end

  # Returns a hash of options for the select field, including the name, value,
  # class, and id.
  def select_input_options(id:, name:, value: nil, required: false)
    input_html_options.merge(      
      name: "#{@builder.object_name}[contributors][][#{name}]",
      value: value,
      class: css_classes('select', required: required),
      id: id_with_prefix(id)
    )
  end

  # Returns a hash of options for the text field, including the name, value,
  # placeholder, class, and id.
  def text_input_options(id:, name:, value: nil, placeholder: "", required: false, long: false)
    input_html_options.merge(
      name: "#{@builder.object_name}[contributors][][#{name}]",
      value: value,
      placeholder: placeholder,
      class: css_classes('string', required: required, long: long),
      id: id_with_prefix(id)
    )
  end

  # Returns a string of CSS classes for the input field, including the default
  # classes on all input fields, any additional classes passed in to the *classes param,
  # and adding on 'required' and 'long' if their boolean params are true.
  def css_classes(*classes, required: false, long: false)
    classes += ["form-control", "child_contributors", "multi-text-field"]
    classes << "required" if required
    classes << "long" if long
    classes.join(" ")
  end

  def id_with_prefix(id)
    # Does just #object_name work here?
    "#{@builder.object_name}_#{attribute_name}_#{id}"
  end

  # Returns a div containing the given fields, with the class "contributor-field-group".
  # @param fields [Array] the fields to include in the group. Each "field" in this case is rendered HTML
  # as returuned from ActionView::Helpers::FormHelper, e.g. #text_field, #select, #hidden_field, etc.
  # This wrapper div allows for custom styling of the Contributors since there are so many fields.
  def contributor_field_group(fields=[])
    tag.div(fields.join.html_safe, class: "contributor-field-group")
  end
end

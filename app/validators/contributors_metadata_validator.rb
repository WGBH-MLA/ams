class ContributorsMetadataValidator < ActiveModel::EachValidator
  FIELD_ORDER = [
    :id,
    :contributor_role,
    :contributor,
    :contributor_role_annotation,
    :portrayal,
    :affiliation,
    :affiliation_annotation,
    :annotation,
    :start_time,
    :end_time,
    :time_annotation
  ]

  def validate_each(record, attribute, contributors_values_arrays)
    # Set instance varaibles accessible with from these params so they are
    # accessible in the validation methods.
    set_instance_vars!(
      record: record,
      attribute: attribute,
      contributors: contributors_from_values_arrays
    )

    contributors.each { |contributor| validate_contributor(contributor) }
  end

  private

  # Sets instance variables for the given key-value pairs and creates accessor
  # methods for them if they don't already exist. This is handy for a "secondary
  # initialization" of an object that is invoked within our application code but
  # not in the constructor, so we need to set instance variables and create
  # accessors for them.
  def set_instance_vars!(**vars_and_vals)
    vars_and_vals.each do |var, val|
      # Set the instance variable
      instance_variable_set("@#{var}", val)
      # Create an accessor method for the instance variable if it doesn't already exist
      self.class.send(:attr_reader, var) unless self.class.method_defined?(var)
    end
  end


  def validate_contributor(contributor)
    validate_name_if_role(contributor)
    validate_time_fields(contributor)
  end

  def validate_name_if_role(contributor)
    if contributor[:contributor_role].present? && contributor[:contributor].blank?
      errors.add(:contributor, "must be present if a role is specified")
    end
  end

  def validate_time_fields
    if contributor[:start_time].present? && contributor[:end_time].present?
      start_time_float = contributor[:start_time].to_f
      end_time_float = contributor[:end_time].to_f
      if contributor[:start_time] > contributor[:end_time]
        errors.add(:start_time, "must be less than or equal to end time")
      end
    end
  end


  # The child_contribution data comes into the validator as an array of arrays (no keys).
  # This method uses that data plus the knowledge of the field order from the form to
  # create an array of hashes that are easier to clearly validate in the validation
  # logic.
  # IMPORTANT NOTE: This validator thus depends on the FIELD_ORDER constant being accurate with respedt
  # to the order of the Contributor fields in the form for the parent AssetResource.
  # If order of the fields change in the Contributor form, then they must change here too.
  def contributors_from_values_arrays(values_arrays)
    values_arrays.map do |values_array|
      Hash[FIELD_ORDER.zip(values_array)]
    end
  end
end

# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource AssetResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class AssetResourceForm < Hyrax::Forms::ResourceForm(AssetResource)
  include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:asset_resource)
  include ChildCreateButton
  include DisabledFields

  attr_accessor :controller, :current_ability

  class_attribute :field_groups

  self.hidden_fields += [ :hyrax_batch_ingest_batch_id, :last_pushed, :last_updated, :needs_update, :bulkrax_importer_id ]

  admin_data_attributes = (AdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym

  self.field_groups = {
    identifying_info: [:titles_with_types, :producing_organization, :local_identifier, :pbs_nola_code, :eidr_id, :asset_types, :dates_with_types, :descriptions_with_types],
    subject_info: [:genre, :topics, :subject, :spatial_coverage, :temporal_coverage, :audience_level, :audience_rating, :annotation],
    rights: [:rights_summary, :rights_link],
    credits: [:child_contributors],
    aapb_admin_data: admin_data_attributes,
    annotations: [:child_annotations]
  }

  def disabled?(field)
    disabled_fields = self.disabled_fields.dup
    disabled_fields += self.field_groups[:aapb_admin_data] if current_ability.cannot?(:create, AdminData)
    disabled_fields.include?(field)
  end

  def hidden?(field)
    hidden_fields = self.hidden_fields.dup
    hidden_fields.include?(field)
  end

  def multiple?(field)
    if [:child_contributors, :child_annotations, :special_collection, :sonyci_id, :special_collection_category].include?(field.to_sym)
      true
    else
      super
    end
  end

  def primary_terms
    []
  end

  def secondary_terms
    []
  end

  def expand_field_group?(group)
    #Get terms for a certian field group
    return true if group == :credits && model.members.map{ |member| member.class }.include?(Contribution)

    #Get terms for a certian field group
    return true if group == :aapb_admin_data && model.admin_data && !model.admin_data.empty?

    field_group_terms(group).each do |term|
      #Expand field group
      return true if !model.attributes[term.to_s].blank? || errors.has_key?(term)
    end
    false
  end

  def field_group_terms(group)
    group_terms = field_groups[group]
    if group == :identifying_info
      group_terms = field_groups[group] - [:titles_with_types, :descriptions_with_types]
      group_terms += [:title, :program_title, :episode_title, :episode_number, :segment_title, :raw_footage_title, :promo_title, :clip_title]
      group_terms += [:description, :episode_description, :segment_description, :raw_footage_description, :promo_description, :clip_description]
    end
    group_terms
  end

  property :child_contributors, virtual: true
  def child_contributors
    child_contributions = []
    model.members.to_a.each do |member|
      if( member.class == Contribution )
        child_contributions << [member.id, member.contributor_role, member.contributor.first , member.portrayal, member.affiliation]
      end
    end
    child_contributions
  end

  property :child_annotations, virtual: true
  def child_annotations
    child_annotations = []

    if model.admin_data
      model.admin_data.annotations.each do |annotation|
        child_annotations << [annotation.id, annotation.admin_data_id, annotation.annotation_type, annotation.ref, annotation.source, annotation.value, annotation.annotation, annotation.version]
      end
    end

    child_annotations
  end

  property :titles_with_types, virtual: true, required: true
  def titles_with_types
    titles_with_types = []
    title_type_service = TitleTypesService.new
    title_types = title_type_service.all_ids
    title_types.each do |title_type|
      model_field = title_type_service.model_field(title_type)
      raise "Unable to find model property" unless model.respond_to?(model_field)
      titles_with_types += model.try(model_field).to_a.map { |title| [title_type, title] }
    end
    titles_with_types
  end

  property :descriptions_with_types, virtual: true, required: true
  def descriptions_with_types
    descriptions_with_types = []
    description_type_service = DescriptionTypesService.new
    types = description_type_service.all_ids
    types.each do |description_type|
      model_field = description_type_service.model_field(description_type)
      raise "Unable to find model property" unless model.respond_to?(model_field)
      descriptions_with_types += model.try(model_field).to_a.map { |value| [description_type, value] }
    end
    descriptions_with_types
  end

  property :dates_with_types, virtual: true
  def dates_with_types
    dates_with_types = []
    date_type_service = DateTypesService.new
    types = date_type_service.all_ids
    types.each do |date_type|
      model_field = date_type_service.model_field(date_type)
      raise "Unable to find model property" unless model.respond_to?(model_field)
      dates_with_types += model.try(model_field).to_a.map { |value| [date_type, value] }
    end
    dates_with_types
  end

  property :sonyci_id, virtual: true
  def sonyci_id
    if model.admin_data
      Array(model.admin_data.sonyci_id)
    else
      []
    end
  end

  property :annotations, virtual: true
  def annotations
    if model.admin_data
      Array(model.admin_data.annotations)
    else
      []
    end
  end

  property :bulkrax_importer_id, virtual: true, display: false, multiple: false
  def bulkrax_importer_id
    if model.admin_data
      model.admin_data.bulkrax_importer_id
    else
      ""
    end
  end

  property :hyrax_batch_ingest_batch_id, virtual: true, multiple: false
  def hyrax_batch_ingest_batch_id
    if model.admin_data
      model.admin_data.hyrax_batch_ingest_batch_id
    else
      ""
    end
  end

  property :last_pushed, virtual: true, display: false, multiple: false
  def last_pushed
    if model.admin_data
      model.admin_data.last_pushed
    else
      ""
    end
  end
  property :last_updated, virtual: true, display: false, multiple: false
  def last_updated
    if model.admin_data
      model.admin_data.last_updated
    else
      ""
    end
  end
  property :needs_update, virtual: true, display: false, multiple: false
  def needs_update
    if model.admin_data
      model.admin_data.needs_update
    else
      ""
    end
  end

  def permitted_params
    @permitted ||= build_permitted_params
  end

  def build_permitted_params
    permitted = []
    (self.class.required_fields + field_groups.values.map(&:to_a).flatten).uniq.each do |term|
      if multiple?(term)
        permitted << { term => [] }
      else
        permitted << term
      end
    end
    permitted
  end

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true
end

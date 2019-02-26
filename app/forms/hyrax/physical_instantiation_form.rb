# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationForm < Hyrax::Forms::WorkForm
    include DisabledFields
    include ChildCreateButton
    include SingleValuedForm
    include InheritParentTitle

    self.model_class = ::PhysicalInstantiation

    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor,
                   :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url,
                   :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:format, :location, :media_type, :holding_organization]

    self.single_valued_fields = [:title]

    #removing id, created_at & updated_at from attributes
    instantiation_admin_data_attributes = (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym

    class_attribute :field_groups

    self.field_groups = {
      identifying_info: [:title, :holding_organization, :local_instantiation_identifier, :media_type, :format, :location, :generations, :date, :digitization_date,
                         :language, :annotation],
      technical_info: [:dimensions, :standard, :duration, :time_start, :colors, :tracks, :channel_configuration,
                       :alternative_modes],
      rights: [:rights_summary, :rights_link],
      instantiation_admin_data: instantiation_admin_data_attributes
    }

    self.terms += (self.required_fields + field_groups.values.map(&:to_a).flatten).uniq

    self.readonly_fields = [:title]
    #self.disabled_fields =  instantiation_admin_data_attributes

    self.field_metadata_service = AAPB::MetadataService

    def primary_terms
      []
    end

    def secondary_terms
      []
    end

    def expand_field_group?(group)
      #Get terms for a certian field group
      field_group_terms(group).each do |term|
        #Get terms for a certian field group
        return true if group == :instantiation_admin_data && model.instantiation_admin_data && !model.instantiation_admin_data.empty?
        #Expand field group
        return true if !model.attributes[term.to_s].blank? || model.errors.has_key?(term)
      end
      false
    end

    def aapb_preservation_lto
      if model.instantiation_admin_data
        model.instantiation_admin_data.aapb_preservation_lto
      else
        ""
      end
    end

    def disabled?(field)
      disabled_fields = self.disabled_fields.dup
      disabled_fields += self.field_groups[:instantiation_admin_data] if current_ability.cannot?(:create, InstantiationAdminData)
      disabled_fields.include?(field)
    end

    def aapb_preservation_disk
      if model.instantiation_admin_data
        model.instantiation_admin_data.aapb_preservation_disk
      else
        ""
      end
    end

    def field_group_terms(group)
      field_groups[group]
    end
  end
end

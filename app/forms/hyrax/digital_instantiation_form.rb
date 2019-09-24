# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  class DigitalInstantiationForm < Hyrax::Forms::WorkForm
    include DisabledFields
    include InheritParentTitle

    self.model_class = ::DigitalInstantiation
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor,
                   :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url,
                   :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:title, :digital_instantiation_pbcore_xml, :location, :holding_organization]

    class_attribute :field_groups

    #removing id, created_at & updated_at from attributes
    instantiation_admin_data_attributes = (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym


    self.field_groups = {
      technical_info: [:local_instantiation_identifier, :media_type, :digital_format, :dimensions, :standard, :file_size,
                       :duration, :time_start, :data_rate, :colors, :tracks, :channel_configuration, :alternative_modes],
      identifying_info: [:title, :holding_organization, :location, :generations, :language, :date, :annotation],
      rights: [:rights_summary, :rights_link],
      instantiation_admin_data: instantiation_admin_data_attributes
    }

    self.terms += (self.required_fields + field_groups.values.map(&:to_a).flatten).uniq

    self.disabled_fields = self.terms - ( [:title, :location, :generations, :language, :date, :annotation, :rights_link, :rights_summary, :holding_organization] + instantiation_admin_data_attributes )
    self.readonly_fields = [:title]

    self.field_metadata_service = AAPB::MetadataService

    def primary_terms
      [:digital_instantiation_pbcore_xml]
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

    def aapb_preservation_disk
      if model.instantiation_admin_data
        model.instantiation_admin_data.aapb_preservation_disk
      else
        ""
      end
    end

    def md5
      if model.instantiation_admin_data
        model.instantiation_admin_data.md5
      else
        ""
      end
    end

    def field_group_terms(group)
      field_groups[group]
    end

    def disabled?(field)
      disabled_fields = self.disabled_fields.dup
      disabled_fields += self.field_groups[:instantiation_admin_data] if current_ability.cannot?(:create, InstantiationAdminData)
      disabled_fields.include?(field)
    end

    def self.model_attributes(form_params)
      clean_params = sanitize_params(form_params)
      terms.each do |key|
        clean_params[key].delete('') if clean_params[key] && multiple?(key)
      end
      clean_params[:title] = Array(clean_params[:title])
      clean_params
    end
  end
end

# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  class DigitalInstantiationForm < Hyrax::Forms::WorkForm
    include ReadOnlyFields

    self.model_class = ::DigitalInstantiation
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor,
                   :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url,
                   :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:title, :digital_instantiation_pbcore_xml, :location]

    class_attribute :field_groups

    self.field_groups = {
      technical_info: [:local_instantiation_identifer, :media_type, :digital_format, :dimensions, :standard, :file_size,
                       :duration, :time_start, :data_rate, :colors, :tracks, :channel_configuration, :alternative_modes],
      identifying_info: [:title, :location, :generations, :language, :date, :annotation],
      rights: [:rights_summary, :rights_link]
    }

    self.terms += (self.required_fields + field_groups.values.map(&:to_a).flatten).uniq

    self.readonly_fields = self.terms - [:title, :location, :generations, :language, :date, :annotation, :rights_link, :rights_summary]

    def primary_terms
      [:digital_instantiation_pbcore_xml]
    end

    def secondary_terms
      []
    end

    def expand_field_group?(group)
      #Get terms for a certian field group
      field_group_terms(group).each do |term|
        #Expand field group
        return true if !model.attributes[term.to_s].blank? || model.errors.has_key?(term)
      end
      false
    end

    def field_group_terms(group)
      field_groups[group]
    end

    def self.model_attributes(form_params)
      clean_params = sanitize_params(form_params)
      terms.each do |key|
        clean_params[key].delete('') if clean_params[key] && multiple?(key)
      end
      clean_params
    end
  end
end

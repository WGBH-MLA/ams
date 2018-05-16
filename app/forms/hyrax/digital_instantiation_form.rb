# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  class DigitalInstantiationForm < Hyrax::Forms::WorkForm
    self.model_class = ::DigitalInstantiation
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor,
                   :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url,
                   :bibliographic_citation, :source]
    self.required_fields -= [:title, :creator, :keyword, :rights_statement]
    self.required_fields += [:digital_instantiation_pbcore_xml]

    class_attribute :field_groups

    self.field_groups = {
      technical_info: [:local_instantiation_identifer, :media_type, :digital_format, :dimensions, :standard, :file_size,
                       :duration, :time_start, :data_rate, :colors, :tracks, :channel_configuration, :alternative_modes],
      identifying_info: [:title, :location, :generations, :language, :date, :annotation],
      rights: [:rights_summary, :rights_statement]
    }

    self.terms += self.required_fields + field_groups.values.map(&:to_a).flatten

    def field_group_empty?(group)
      field_group_terms(group).each do |term|
        return true if model.attributes[term.to_s].any?
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

# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  class DigitalInstantiationForm < Hyrax::Forms::WorkForm
    self.model_class = ::DigitalInstantiation
    self.terms += [:digital_instantiation_pbcore_xml]
    self.terms += [:date, :dimensions, :digital_format, :standard, :location, :media_type, :generations,:file_size, :time_start, :duration, :data_rate, :colors, :rights_summary, :rights_link, :annotation]
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:digital_instantiation_pbcore_xml, :location]

    def self.model_attributes(form_params)
      clean_params = sanitize_params(form_params)
      terms.each do |key|
        clean_params[key].delete('') if clean_params[key] && multiple?(key)
      end
      clean_params
    end

    def primary_terms
      if self.agreement_accepted
        return self.required_fields -= [:digital_instantiation_pbcore_xml]
      end
      self.required_fields
    end

  end
end
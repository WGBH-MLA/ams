# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  class DigitalInstantiationForm < Hyrax::Forms::WorkForm
    self.model_class = ::DigitalInstantiation
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:title, :creator, :keyword, :rights_statement]
    self.required_fields += [:digital_instantiation_pbcore_xml]

    class_attribute :technical_info, :identifying_info , :rights

    self.technical_info = [:local_instantiation_identifer, :media_type, :digital_format, :dimensions, :standard, :file_size, :duration, :time_start, :data_rate, :colors, :tracks, :channel_configuration, :alternative_modes]
    self.identifying_info = [:title, :location, :generations, :language, :date, :annotation]
    self.rights = [:rights_summary, :rights_statement]

    self.terms += self.required_fields + self.technical_info +  self.identifying_info + self.rights

    def self.model_attributes(form_params)
      clean_params = sanitize_params(form_params)
      terms.each do |key|
        clean_params[key].delete('') if clean_params[key] && multiple?(key)
      end
      clean_params
    end

    end
end

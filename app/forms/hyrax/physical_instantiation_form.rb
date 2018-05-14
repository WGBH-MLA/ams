# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationForm < Hyrax::Forms::WorkForm
    self.model_class = ::PhysicalInstantiation

    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:title, :creator, :keyword, :rights_statement]

    class_attribute :technical_info, :identifying_info , :rights

    self.identifying_info = [:title, :local_instantiation_identifer, :media_type, :format, :location, :generations, :date, :language, :annotiation]
    self.technical_info = [:dimensions, :standard, :duration, :time_start, :colors, :tracks, :channel_configuration, :alternative_modes]
    self.rights = [:rights_summary, :rights_statement]

    self.terms += self.required_fields + self.technical_info +  self.identifying_info + self.rights


  end
end

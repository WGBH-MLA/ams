# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationForm < Hyrax::Forms::WorkForm
    self.model_class = ::PhysicalInstantiation
    self.terms += [:date, :digitization_date, :dimensions, :format, :standard, :location, :media_type, :generations, :time_start, :duration, :colors, :rights_summary, :rights_link, :annotiation]
    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:media_type, :format, :location]
  end
end
# Generated via
#  `rails generate hyrax:work Series`
module Hyrax
  class SeriesForm < Hyrax::Forms::WorkForm
    self.model_class = ::Series
    self.terms += [:resource_type, :audience_level, :audience_rating, :annotation, :rights_summary, :rights_link]
    self.terms -= [:relative_path, :import_url, :date_created, :resource_type, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :language, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields += [:description]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end

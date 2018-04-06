# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetForm < Hyrax::Forms::WorkForm
    self.model_class = ::Asset
    self.terms += [:asset_types, :resource_type, :broadcast, :created, :date, :copyright_date, :episode_number, :description, :spatial_coverage, :temporal_coverage, :audience_level, :audience_rating, :annotiation, :rights_summary, :rights_link]
    self.terms -= [:relative_path, :import_url, :date_created, :resource_type, :creator, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :language, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields += [:description]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end

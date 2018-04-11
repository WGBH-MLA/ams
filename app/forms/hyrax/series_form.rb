# Generated via
#  `rails generate hyrax:work Series`
module Hyrax
  class SeriesForm < Hyrax::Forms::WorkForm
    self.model_class = ::Series
    self.terms += [:resource_type, :audience_level, :audience_rating, :annotation, :rights_summary, :rights_link]
    self.terms -= [:relative_path, :import_url, :date_created, :resource_type, :contributor, :keyword, :license, :rights_statement, :publisher, :subject, :language, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields += [:description]
    self.required_fields -= [:creator, :keyword, :rights_statement]

    # Delegate #assets and #assets_attributes= to the Series model.
    # The #assets method comes from Series.has_and_belongs_to_many(:assets).
    # The #assets_attributes= method comes from
    # Series.accetps_nested_attributes_for(:assets).
    # See app/models/series.rb
    delegate :assets, :asset_attributes=, to: :model
  end
end

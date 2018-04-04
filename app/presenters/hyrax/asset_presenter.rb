# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetPresenter < Hyrax::WorkShowPresenter
    delegate :broadcast, :created, :copyright_date, :episode_number, :description, :spatial_coverage, :temporal_coverage, :audience_level, :audience_rating, :annotiation, :rights_summary, :rights_link, :date, to: :solr_document
  end
end

# Generated via
#  `rails generate hyrax:work Series`
module Hyrax
  class SeriesPresenter < Hyrax::WorkShowPresenter
    delegate :description, :audience_level, :audience_rating, :annotation, :rights_summary, :rights_link, to: :solr_document
  end
end

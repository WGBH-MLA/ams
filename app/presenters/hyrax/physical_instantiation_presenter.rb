# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationPresenter < Hyrax::WorkShowPresenter
    delegate :date, :digitization_date, :dimensions, :digital_format, :standard, :location, :media_type, :generations, :time_start, :duration, :colors, :language, :rights_summary, :rights_link, :annotation, to: :solr_document
  end
end
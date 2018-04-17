# Generated via
#  `rails generate hyrax:work EssenceTrack`
module Hyrax
  class EssenceTrackPresenter < Hyrax::WorkShowPresenter
    delegate :date, :dimensions, :format, :standard, :location, :media_type, :generations, :file_size, :time_start, :duration, :data_rate, :colors, :language, :rights_summary, :rights_link, :annotation, to: :solr_document
  end
end
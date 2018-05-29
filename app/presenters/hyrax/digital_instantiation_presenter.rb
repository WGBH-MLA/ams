# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  class DigitalInstantiationPresenter < Hyrax::WorkShowPresenter
    delegate :date, :dimensions, :digital_format, :standard, :location, :media_type, :generations, :file_size, :time_start, :duration,
             :data_rate, :colors, :language, :rights_summary, :rights_link, :annotation, :local_instantiation_identifer, :tracks,
             :channel_configuration, :alternative_modes, :holding_organization, to: :solr_document
  end
end

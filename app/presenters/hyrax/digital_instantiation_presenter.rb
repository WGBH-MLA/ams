# Generated via
#  `rails generate hyrax:work DigitalInstantiation`
module Hyrax
  class DigitalInstantiationPresenter < Hyrax::WorkShowPresenter
    delegate :date, :dimensions, :digital_format, :standard, :location, :media_type, :generations, :file_size, :time_start, :duration,
             :data_rate, :colors, :language, :rights_summary, :rights_link, :annotation, :local_instantiation_identifier, :tracks,
             :channel_configuration, :alternative_modes, :holding_organization, :aapb_preservation_lto, :aapb_preservation_disk, to: :solr_document

    def attribute_to_html(field, options = {})
      options.merge!({:html_dl=> true})
      super(field, options)
    end
  end
end

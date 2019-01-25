# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationPresenter < Hyrax::WorkShowPresenter
    delegate :date, :digitization_date, :dimensions, :format, :standard, :location, :media_type, :generations, :time_start, :duration, :colors,
             :language, :rights_summary, :rights_link, :annotation, :local_instantiation_identifier, :tracks, :channel_configuration,
             :alternative_modes, :holding_organization, to: :solr_document

    def attribute_to_html(field, options = {})
      options.merge!({:html_dl=> true})
      super(field, options)
    end
  end
end

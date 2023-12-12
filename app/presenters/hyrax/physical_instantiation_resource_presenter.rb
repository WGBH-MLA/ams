# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationResourcePresenter < Hyrax::WorkShowPresenter
    include AAPB::InstantiationAdminDataPresenter
    include AAPB::AttributeIndexedToParentPresenter

    delegate :date, :digitization_date, :dimensions, :format, :standard, :location, :media_type, :generations, :time_start, :duration, :colors,
             :language, :rights_summary, :rights_link, :annotation, :local_instantiation_identifier, :tracks, :channel_configuration,
             :alternative_modes, :holding_organization, :aapb_preservation_lto, :aapb_preservation_disk, to: :solr_document
  end
end

# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationForm < Hyrax::Forms::WorkForm
    include DisabledFields
    include ChildCreateButton

    self.model_class = ::PhysicalInstantiation

    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor,
                   :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url,
                   :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.required_fields += [:format, :location, :media_type, :holding_organization]

    class_attribute :field_groups

    self.field_groups = {
      identifying_info: [:title, :holding_organization, :local_instantiation_identifer, :media_type, :format, :location, :generations, :date, :digitization_date,
                         :language, :annotiation],
      technical_info: [:dimensions, :standard, :duration, :time_start, :colors, :tracks, :channel_configuration,
                       :alternative_modes],
      rights: [:rights_summary, :rights_link]
    }

    self.terms += (self.required_fields + field_groups.values.map(&:to_a).flatten).uniq

    self.readonly_fields = [:title]

    self.field_metadata_service = WGBH::MetadataService

    def title
      if @controller.params.has_key?(:parent_id)
        parent_object = ActiveFedora::Base.find(@controller.params[:parent_id])
        if(parent_object.title.any?)
          return [parent_object.title.first]
        end
      end
      []
    end

    def self.model_attributes(form_params)
      clean_params = sanitize_params(form_params)
      clean_params[:title] = Array(clean_params[:title])
      clean_params
    end

    def primary_terms
      []
    end

    def secondary_terms
      []
    end

    def expand_field_group?(group)
      #Get terms for a certian field group
      field_group_terms(group).each do |term|
        #Expand field group
        return true if !model.attributes[term.to_s].blank? || model.errors.has_key?(term)
      end
      false
    end

    def field_group_terms(group)
      field_groups[group]
    end
  end
end

# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  class PhysicalInstantiationForm < Hyrax::Forms::WorkForm
    self.model_class = ::PhysicalInstantiation

    self.terms -= [:description, :relative_path, :import_url, :date_created, :resource_type, :creator, :contributor,
                   :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url,
                   :bibliographic_citation, :source]
    self.required_fields -= [:title, :creator, :keyword, :rights_statement]

    class_attribute :field_groups

    self.field_groups = {
      identifying_info: [:title, :local_instantiation_identifer, :media_type, :format, :location, :generations, :date,
                         :language, :annotiation],
      technical_info: [:dimensions, :standard, :duration, :time_start, :colors, :tracks, :channel_configuration,
                       :alternative_modes],
      rights: [:rights_summary, :rights_statement]
    }

    self.terms += self.required_fields + field_groups.values.map(&:to_a).flatten

    def field_group_empty?(group)
      field_group_terms(group).each do |term|
        return true if model.attributes[term.to_s].any?
      end
      false
    end

    def field_group_terms(group)
      field_groups[group]
    end
  end
end

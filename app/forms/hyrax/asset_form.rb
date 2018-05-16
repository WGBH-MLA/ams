# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetForm < Hyrax::Forms::WorkForm
    self.model_class = ::Asset

    # Remove terms that we don't want to be a part of the form.
    self.terms -= [:relative_path, :import_url, :date_created, :resource_type,
                   :creator, :contributor, :keyword, :license,
                   :rights_statement, :publisher, :language, :identifier,
                   :based_near, :related_url, :bibliographic_citation, :source,
                   :title, :description]

    # Add fields that we want to be required
    self.required_fields += [:titles_with_types, :descriptions_with_types]

    # Remove fields tha we don't want to be required.
    self.required_fields -= [:creator, :keyword, :rights_statement, :title, :description]

    class_attribute :field_groups

    self.field_groups = {
      identifying_info: [:titles_with_types, :local_identifier, :pbs_nola_code, :eidr_id, :asset_types, :date, :descriptions_with_types],
      subject_info: [:genre, :topics, :subject, :spatial_coverage, :temporal_coverage, :audience_level, :audience_rating, :annotation],
      rights: [:rights_summary, :rights_statement]
    }

    self.terms += self.required_fields + self.field_groups.values.map(&:to_a).flatten

    # These methods are necessary to prevent the form builder from blowing up.
    def title_type; end

    def title_value; end

    def description_type; end

    def description_value; end

    def field_group_empty?(group)
      field_group_terms(group).each do |term|
        return true if model.attributes["#{term.to_s}"].any?
      end
      false
    end

    def field_group_terms(group)
      local_terms = self.field_groups[group].clone
      if(group == :identifying_info)
        local_terms.delete(:titles_with_types)
        local_terms.delete(:descriptions_with_types)
        local_terms += [:title, :program_title, :episode_title, :segment_title, :raw_footage_title, :promo_title, :clip_title]
        local_terms += [:description, :episode_description, :segment_description, :raw_footage_description, :promo_description, :clip_description]
      end
      local_terms
    end

    def titles_with_types
      titles_with_types = []
      titles_with_types += model.title.map { |title| ['main', title] }
      titles_with_types += model.program_title.map { |title| ['program', title] }
      titles_with_types += model.episode_title.map { |title| ['episode', title] }
      titles_with_types += model.segment_title.map { |title| ['segment', title] }
      titles_with_types += model.raw_footage_title.map { |title| ['raw_footage', title] }
      titles_with_types += model.promo_title.map { |title| ['promo', title] }
      titles_with_types += model.clip_title.map { |title| ['clip', title] }
      titles_with_types
    end

    def descriptions_with_types
      descriptions_with_types = []
      descriptions_with_types += model.description.map { |description| ['main', description] }
      descriptions_with_types += model.episode_description.map { |description| ['episode', description] }
      descriptions_with_types += model.segment_description.map { |description| ['segment', description] }
      descriptions_with_types += model.raw_footage_description.map { |description| ['raw_footage', description] }
      descriptions_with_types += model.promo_description.map { |description| ['promo', description] }
      descriptions_with_types += model.clip_description.map { |description| ['clip', description] }
      descriptions_with_types
    end

    # Augment the list of permmitted params to accept our fields that have
    # types associated with them, e.g. title + title type
    # NOTE: `super` in this case is HyraxEditor::Form.permitted_params
    def self.permitted_params
      super.tap do |permitted_params|
        permitted_params << { title_type: [] }
        permitted_params << { title_value: [] }
        permitted_params << { description_type: [] }
        permitted_params << { description_value: [] }
      end
    end
  end
end

# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetForm < Hyrax::Forms::WorkForm
    self.model_class = ::Asset

    # Add terms tha we want to be a part of the "Additional Fields" section
    self.terms += [:genre, :asset_types, :resource_type, :episode_number, :spatial_coverage,
                   :temporal_coverage, :audience_level, :audience_rating, :annotation,
                   :rights_summary, :rights_link, :local_identifier, :pbs_nola_code, :eidr_id,
                   :topics, :dates_with_types, :titles_with_types, :descriptions_with_types]

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


    # These methods are necessary to prevent the form builder from blowing up.
    def title_type; end
    def title_value; end
    def description_type; end
    def description_value; end
    def date_type; end
    def date_value; end

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

    def dates_with_types
      dates_with_types = []
      dates_with_types += model.broadcast_date.map { |date| ['broadcast', date] }
      dates_with_types += model.created_date.map { |date| ['created', date] }
      dates_with_types += model.copyright_date.map { |date| ['copyright', date] }
      dates_with_types
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
        permitted_params << { date_type: [] }
        permitted_params << { date_value: [] }
      end
    end
  end
end

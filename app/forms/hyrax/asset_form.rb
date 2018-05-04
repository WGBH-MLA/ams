# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetForm < Hyrax::Forms::WorkForm

    self.model_class = ::Asset
    # Add terms tha we want to be a part of the "Additional Fields" section
    self.terms += [:genre, :asset_types, :resource_type, :broadcast, :created, :date, :copyright_date,
                   :episode_number, :description, :spatial_coverage, :temporal_coverage, :audience_level,
                   :audience_rating, :annotation, :rights_summary, :rights_link, :local_identifier, :pbs_nola_code,
                   :eidr_id, :topics]

    # Remove terms that we don't want to be a part of the form.
    self.terms -= [:relative_path, :import_url, :date_created, :resource_type,
                   :creator, :contributor, :keyword, :license,
                   :rights_statement, :publisher, :language, :identifier,
                   :based_near, :related_url, :bibliographic_citation, :source,
                   :episode_title, :segment_title, :raw_footage_title,
                   :promo_title, :clip_title]

    # Add fields that we want to be required
    self.required_fields += [:titles_with_types, :description]

    # Remove fields tha we don't want to be required.
    self.required_fields -= [:creator, :keyword, :rights_statement, :title]


    def title_type
      # This is a fucking pointless no-op method that is stupidly required
      # by form builder object, because we can't use form builder object to build
      # forms containing arbitrary form inputs, no we can't. We absolutely must have
      # a corresponding method in the form object that was passed to the form builder
      # or else we get fatal errors. So here's a method that does nothing in order to
      # make the machinery work. Yay.
      # TODO: Is this really necessary? C'mon.
    end

    def title_value
      # See #title_type method.
    end

    def titles_with_types
      titles_with_types = []
      titles_with_types += model.title.map { |title| [:default, title] }
      titles_with_types += model.episode_title.map { |title| [:episode, title] }
      titles_with_types += model.segment_title.map { |title| [:segment, title] }
      titles_with_types += model.raw_footage_title.map { |title| [:raw_footage, title] }
      titles_with_types += model.promo_title.map { |title| [:promo, title] }
      titles_with_types += model.clip_title.map { |title| [:clip, title] }
      titles_with_types
    end

    # Augment the list of permmitted params to accept our fields that have
    # types associated with them, e.g. title + title type
    # NOTE: `super` in this case is HyraxEditor::Form.permitted_params
    def self.permitted_params
      super.tap do |permitted_params|
        permitted_params << { title_type: [] }
        permitted_params << { title_value: [] }
      end
    end
  end
end

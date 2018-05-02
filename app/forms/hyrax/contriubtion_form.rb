# Generated via
#  `rails generate hyrax:work Contriubtion`
module Hyrax
  class ContriubtionForm < Hyrax::Forms::WorkForm
    self.model_class = ::Contriubtion
    self.terms += [ :contributor_role, :portrayal]
    self.terms -= [:language, :description, :relative_path, :import_url, :date_created, :resource_type, :creator, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]

    def self.multiple?(field)
      byebug
      if [:title, :contributor].include? field.to_sym
        false
      else
        super
      end
    end

    def self.model_attributes(_)
      attrs = super
      attrs[:title] = Array(attrs[:title]) if attrs[:title]
      attrs[:contributor] = Array(attrs[:contributor]) if attrs[:contributor]
      attrs
    end

    def title
      super.first || ""
    end

    def contributor
      super.first || ""
    end

  end
end

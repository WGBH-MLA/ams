# Generated via
#  `rails generate hyrax:work Contribution`
module Hyrax
  class ContributionForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Contribution
    self.terms += [ :contributor_role, :portrayal]
    self.terms -= [:language, :description, :relative_path, :import_url, :date_created, :resource_type, :creator, :keyword, :license, :rights_statement, :publisher, :subject, :identifier, :based_near, :related_url, :bibliographic_citation, :source]
    self.required_fields -= [:creator, :keyword, :rights_statement]
    self.single_valued_fields = [:title, :contributor]
  end
end

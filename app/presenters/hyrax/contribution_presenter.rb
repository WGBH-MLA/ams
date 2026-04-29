# Generated via
#  `rails generate hyrax:work Contribution`
module Hyrax
  class ContributionPresenter < Hyrax::WorkShowPresenter
    delegate :contributor_role, :portrayal, :affiliation, :annotation, to: :solr_document
  end
end

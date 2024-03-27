# Generated via
#  `rails generate hyrax:work Contribution`
module Hyrax
  class ContributionResourcePresenter < Hyrax::WorkShowPresenter
    delegate :contributor_role, :portrayal, :affiliation,  to: :solr_document
  end
end

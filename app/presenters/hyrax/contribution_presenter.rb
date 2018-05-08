# Generated via
#  `rails generate hyrax:work Contribution`
module Hyrax
  class ContributionPresenter < Hyrax::WorkShowPresenter
    delegate :contributor_role, :portrayal,  to: :solr_document
  end
end

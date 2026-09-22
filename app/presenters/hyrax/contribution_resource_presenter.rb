# Generated via
#  `rails generate hyrax:work Contribution`
module Hyrax
  class ContributionResourcePresenter < Hyrax::WorkShowPresenter
    delegate :contributor_role,
             contributor_role_annotation,
             :affiliation,
             :affiliation_annotation,
             :portrayal,
             :annotation,
             :start_time,
             :end_time,
             :time_annotation,
             to: :solr_document
  end
end

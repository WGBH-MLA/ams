# Generated via
#  `rails generate hyrax:work Contribution`
module Hyrax
  module Actors
    class ContributionActor < Hyrax::Actors::BaseActor
      def create(env)
        if App.rails_5_1?
          # queue indexing if we are importing
          env.curation_concern.reindex_extent = "queue#{env.importing.id}" if env.importing
        end
        super
      end

      def update(env)
        if App.rails_5_1?
          # queue indexing if we are importing
          env.curation_concern.reindex_extent = "queue#{env.importing.id}" if env.importing
        end
        super
      end
    end
  end
end

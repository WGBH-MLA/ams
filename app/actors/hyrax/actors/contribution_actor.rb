# Generated via
#  `rails generate hyrax:work Contribution`
module Hyrax
  module Actors
    class ContributionActor < Hyrax::Actors::BaseActor
      def create(env)
        # queue indexing if we are importing
        env.curation_concern.reindex_extent = "queue#{env.importing.id}" if env.importing
        super
      end

      def update(env)
        env.curation_concern.reindex_extent = "queue#{env.importing.id}" if env.importing
        super
      end
    end
  end
end

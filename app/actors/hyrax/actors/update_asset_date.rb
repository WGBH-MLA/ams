module Hyrax
  module Actors
    class UpdateAssetDate < Hyrax::Actors::BaseActor
      def create(env)
        update_asset_date(env)
        next_actor.create(env)
      end

      def update(env)
        update_asset_date(env)
        next_actor.update(env)
      end

      private
      def update_asset_date(env)
        # getcha mom
        parent = env.curation_concern.parent_works.first

        # go up to an asset if necce
        if parent && [DigitalInstantiation,PhysicalInstantiation].any? { |cls| parent.is_a?(cls) }
          parent = parent.parent_works.first
        end

        # if its a asset
        unless parent
          parent = env.curation_concern
        end

        if parent
          admindata = parent.admin_data
          admindata.last_updated = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
          admindata.save
          # force update of solr, my friend
          parent.update_index
        end
      end

    end
  end
end

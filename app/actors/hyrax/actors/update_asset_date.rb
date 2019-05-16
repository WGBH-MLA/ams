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
        # todo check if things are saved twice up in here

        # getcha mom
        parent = env.curation_concern.parent_works.first

        # go up to an asset if necce
        if [DigitalInstantiation,PhysicalInstantiation].any? { |cls| parent.is_a?(cls) }
          parent = parent.parent_works.first
        end

        admindata = parent.admin_data
        admindata.last_updated = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
        admindata.save
      end

    end
  end
end

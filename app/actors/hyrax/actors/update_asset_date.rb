module Hyrax
  module Actors
    class UpdateAssetDate < Hyrax::Actors::BaseActor
      def create(env)
        update_asset_date(env) && next_actor.create(env)
      end

      def update(env)
        update_asset_date(env) && next_actor.update(env)
      end

      private
      def update_asset_date(env)

        # handled by its parent job
        return true if env.curation_concern.is_a? Contribution
        # getcha mom
        parent = env.curation_concern.in_objects.first

        # go up to an asset if necce
        if parent && [DigitalInstantiation,PhysicalInstantiation].any? { |cls| parent.is_a?(cls) }
          parent = parent.in_objects.first
        end

        # if its a asset
        unless parent
          parent = env.curation_concern
        end

        if parent && defined? parent.admin_data
          admindata = parent.admin_data

          if admindata

            admindata.last_updated = Time.now.to_i
            admindata.needs_update = true

            admindata.last_pushed = 0 unless admindata.last_pushed
            admindata.save!
            # force update of solr, my friend
            parent.update_index
          end
        end

        true
      end

    end
  end
end

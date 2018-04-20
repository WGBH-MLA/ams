module Hyrax
  module Actors
    # Attach or remove child works to/from this work. This decodes parameters
    # that follow the rails nested parameters conventions:
    # e.g.
    #   'series_assets_attributes' => {
    #     '0' => { 'id' = '12312412'},
    #     '1' => { 'id' = '99981228', '_destroy' => 'true' }
    #   }
    #
    # The goal of this actor is to mutate the ordered_members with as few writes
    # as possible, because changing ordered_members is slow. This class only
    # writes changes, not the full ordered list.
    class AddAssetsToSeriesActor < Hyrax::Actors::AbstractActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        series_asset_attributes = env.attributes.delete(:work_member_attributes)
        series = env.curation_concern
        assign_nested_attributes_for_series(series, series_asset_attributes) &&
          next_actor.update(env)
      end

      private

        # Attaches any unattached Assets.  Deletes those that are marked _delete
        # @param [Hash<Hash>] an array of Asset attribute hashes
        def assign_nested_attributes_for_series(series, series_asset_attributes)
          return true unless series_asset_attributes

          series_asset_attributes = series_asset_attributes.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes }

          # checking for existing works to avoid rewriting/loading works that are
          # already attached
          existing_assets = series.asset_ids
          series_asset_attributes.each do |attributes|
            next if attributes['id'].blank?
            if existing_assets.include?(attributes['id'])
              remove(series, attributes['id']) if has_destroy_flag?(attributes)
            else
              add(series, attributes['id'])
            end
          end
        end

        # Adds the item to the ordered members so that it displays in the items
        # along side the FileSets on the show page
        def add(series, id)
          asset = Asset.find(id)
          series.assets << asset
        end

        # Remove the object from the members set and the ordered members list
        def remove(series, id)
          asset = Asset.find(id)
          series.assets.delete(asset)
          series.assets.delete(asset)
        end

        # Determines if a hash contains a truthy _destroy key.
        # rubocop:disable Style/PredicateName
        def has_destroy_flag?(hash)
          ActiveFedora::Type::Boolean.new.cast(hash['_destroy'])
        end
      # rubocop:enable Style/PredicateName
    end
  end
end

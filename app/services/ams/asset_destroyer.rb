module AMS
  class AssetDestroyer
    attr_accessor :asset_ids, :user_email

    def initialize(asset_ids: [], user_email: nil)
      @asset_ids = Array(asset_ids)
      @user_email = user_email
    end

    def destroy(asset_ids)
      puts "Initiating destruction sequence for #{asset_ids.count} Assets..."
      Array(asset_ids).each do |asset_id|
        destroy_asset_by_id asset_id
      end
    end

    private

      def destroy_asset_by_id(asset_id)
        asset = Asset.find asset_id
        actor.destroy(actor_env(asset))
        puts "Asset '#{asset_id}' destroyed."
      rescue => e
        msg = e.class.to_s
        msg += ": #{e.message}" unless e.message.empty?
        puts "Error destroying Asset '#{asset_id}'. #{msg}"
      end

      def actor
        @actor ||= Hyrax::CurationConcern.actor
      end

      def actor_env(asset)
        # Don't memoize. Needs to reinitialize with each asset.
        Hyrax::Actors::Environment.new(asset, ability, {})
      end

      def ability
        @ability ||= Ability.new(user)
      end

      def user
        @user ||= User.find_by_email user_email
      end
  end
end

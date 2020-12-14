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

    def eradicate_tombstones(asset_ids)
      puts "Initiating eradication sequence for #{asset_ids.count} Tombstones..."
      Array(asset_ids).each do |asset_id|
        begin
          Asset.find asset_id
        rescue Ldp::Gone
          eradicate_tombstone_by_id asset_id
          delete_sipity_entity_by_id asset_id
        else
          puts "Lookup of Asset with ID '#{asset_id}', did not return a Tombstone. Skipping..."
        end
      end
    end

    private

      def destroy_asset_by_id(asset_id)
        asset = Asset.find asset_id
        actor.destroy(actor_env(asset))

        # Also delete the tombstone in Fedora and Sipity::Entity
        eradicate_tombstone_by_id asset_id
        delete_sipity_entity_by_id asset_id

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

      def global_id(asset_id)
        "gid://ams/Asset/'#{asset_id}'"
      end

      def eradicate_tombstone_by_id(asset_id)
         ActiveFedora::Base.eradicate(asset_id)
         puts "Tombstone '#{asset_id}' destroyed."
       rescue => e
        msg = e.class.to_s
        msg += ": #{e.message}" unless e.message.empty?
        puts "Error destroying Fedora Tombstone '#{asset_id}'. #{msg}"
      end

      def delete_sipity_entity_by_id(asset_id)
        Sipity::Entity.find_by(proxy_for_global_id: global_id(asset_id)).destroy
        puts "Sipity::Entity '#{asset_id}' destroyed."
      end
  end
end

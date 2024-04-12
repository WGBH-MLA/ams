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

    def eradicate_asset_tombstones(asset_ids)
      puts "Initiating eradication sequence for #{asset_ids.count} Asset Tombstones..."
      Array(asset_ids).each do |asset_id|
        begin
          Asset.find asset_id
        rescue Ldp::Gone
          eradicate_tombstone_by_id(asset_id)
          # May as well try the Sipity::Entity too
          delete_sipity_entity_by_id(asset_id)
        else
          puts "Lookup of Asset with ID '#{asset_id}' did not return a Tombstone. Skipping..."
        end
      end
    end

    private

      def destroy_asset_by_id(asset_id)
        # Order is important! When looking up a record, if it is found in Fedora but not Postgres,
        # the record in Fedora is copied over to Postgres.
        destroy_in_fedora(asset_id)
        destroy_in_postgres(asset_id)
      end

      def destroy_in_fedora(asset_id)
        asset = Asset.find asset_id

        # Get IDs required to delete associated Tombstones and Sipity::Entities
        all_member_ids = [ asset.id ] + asset.all_members.map(&:id)

        # Use ActorStack to destroy front-end Asset and Associated Objects
        actor.destroy(actor_env(asset))
        puts "Asset '#{asset_id}' destroyed."

        # Also delete the Tombstone in Fedora and Sipity::Entity
        all_member_ids.each do |id|
          eradicate_tombstone_by_id(id)
          delete_sipity_entity_by_id(id)
        end
      rescue => e
        error_rescue(e, "Asset", asset_id)
      end

      def destroy_in_postgres(asset_id)
        asset_resource = AssetResource.find(asset_id)

        Hyrax::Transactions::Container['work_resource.destroy']
          .with_step_args('work_resource.delete' => { user: user },
                          'work_resource.delete_all_file_sets' => { user: user })
          .call(asset_resource).value!
      rescue Valkyrie::Persistence::ObjectNotFoundError
        puts "No AssetResource found with ID #{asset_id}"
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

      def map_asset_members(asset)
        members = {}
        members[asset.id] = "Asset"
        asset.members.each do |member|
          members[member.id] = member.class.to_s
        end
        members
      end

      def eradicate_tombstone_by_id(id)
        ActiveFedora::Base.eradicate id
        puts "Tombstone '#{id}' destroyed."
      rescue => e
        error_rescue(e, "Tombstone", id)
      end

      def delete_sipity_entity_by_id(id)
        entity = Sipity::Entity.where("proxy_for_global_id LIKE :object_id", object_id: "%#{id}")
        raise "Returned multiple Sipity::Entities for ID '#{id}" if entity.length > 1
        entity.first.destroy

        puts "Sipity::Entity '#{id}' destroyed."
      rescue => e
        error_rescue(e, "Sipity::Entity", id)
      end

      def error_rescue(error, object_type, id)
        msg = error.class.to_s
        msg += ": #{error.message}" unless error.message.empty?
        puts "Error destroying '#{object_type}' for '#{id}'. #{msg}"
      end
  end
end

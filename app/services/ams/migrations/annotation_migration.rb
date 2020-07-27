module AMS
  module Migrations
    class AnnotationMigration
      attr_accessor :asset_ids, :errors

      FIELDS_TO_MIGRATE = [ :level_of_user_access, :minimally_cataloged, :outside_url, :special_collection, :transcript_status, :licensing_info, :playlist_group, :playlist_order, :organization, :special_collection_category, :canonical_meta_tag ]

      FIELDS_WITH_MAP = { :minimally_cataloged => :cataloging_status, :special_collection => :special_collections }

      def initialize
        # Use Assets because they are 1-to-1 with AdminData
        # and we want to use the AssetActor for indexing
        # Asset.all fails if something is in Solr but not Fedora.
        # This ActiveFedora method actually gets the IDs from Solr, I believe,
        # and then we check for existence in Fedora.
        # This is all to avoid potential errors in indexing that this script isn't
        # meant to solve.
        @asset_ids = ActiveFedora::Base.search_with_conditions( { has_model_ssim: 'Asset' }, { rows: 50000 } ).map{ |asset| asset["id"] }
        @errors = []
      end

      def run
        migrate_data(asset_ids)
        puts @errors
      end

      private

      def migrate_data(asset_ids)
        processed_assets = []

        asset_ids.each do |id|
          puts "PROCESSING ASSET ID: #{id}"
          asset = find_asset(id)
          next if asset.nil?

          admin_data = asset.admin_data
          next if admin_data.nil?

          hot_package = []
          FIELDS_TO_MIGRATE.each do |field|
            field_value = admin_data.send(field)
            next if field_value.nil?
            next if field_value.is_a?(Array) && field_value.empty?

            # Deals with fields that don't precisely track to new annotation_type ids
            field_name = ( FIELDS_WITH_MAP.keys.include?(field) ? FIELDS_WITH_MAP[field] : field )

            if [ :special_collections, :special_collection_category ].include?(field_name)
              field_value[0..-1].each do |v|
                anno = Annotation.new(admin_data_id: admin_data.id, annotation_type: field_name.to_s, value: v)
                if anno.valid?
                  puts "ADDING ANNOTATION TO PACKAGE: [ ADMIN_DATA_ID: #{admin_data.id}, TYPE: #{field_name.to_s}, VALUE: #{v} ]"
                  hot_package << anno
                  field_value.delete(v)
                else
                  @errors << "Annotations Migration Error: Annotation invalid for AdminData object( id: #{admin_data.id.to_s}, #{field_name}: #{v} \n"
                end
              end
              admin_data.send("#{field_name}=", field_value) unless FIELDS_WITH_MAP.values.include?(field_name)
              admin_data.send("#{FIELDS_WITH_MAP.key(field_name)}=", field_value) if FIELDS_WITH_MAP.values.include?(field_name)
            else
              anno = Annotation.new(admin_data_id: admin_data.id, annotation_type: field_name.to_s, value: field_value)
              if anno.valid?
                puts "ADDING ANNOTATION TO PACKAGE: [ ADMIN_DATA_ID: #{admin_data.id}, TYPE: #{field_name.to_s}, VALUE: #{field_value} ]"
                hot_package << anno
                admin_data.send("#{field_name}=", nil) unless FIELDS_WITH_MAP.values.include?(field_name)
                admin_data.send("#{FIELDS_WITH_MAP.key(field_name)}=", nil) if FIELDS_WITH_MAP.values.include?(field_name)
              else
                @errors << "Annotations Migration Error: Annotation invalid for AdminData object( id: #{admin_data.id.to_s}, #{field_name}: #{field_value} \n"
              end
            end
          end

          if hot_package.map(&:class).include?(Annotation)
            puts "ADDING ASSET TO PACKAGE: #{asset.id}"
            hot_package << asset if hot_package.map(&:class).include?(Annotation)
          end

          if hot_package.map(&:class).include?(Asset) && hot_package.map(&:class).include?(Annotation)
            puts "SAVING PACKAGE FOR: #{asset.id}"

            ActiveRecord::Base.transaction do
              hot_package.map(&:save!)
            end
          else
            puts "SKIPPING PACKAGE FOR: #{asset.id}"
          end

        end
        puts "WE'RE DONE HERE.\n"

        if errors.any?
          puts "HERE ARE YOUR ERRORS:\n"

          errors.each do |error|
            puts error
          end
        end
      end

      def find_asset(id)
        # Is the asset REALLY in Fedora?
        asset = Asset.find(id)
        return asset
      rescue
        # It ain't there, so nil for skipping
        nil
      end
    end
  end
end

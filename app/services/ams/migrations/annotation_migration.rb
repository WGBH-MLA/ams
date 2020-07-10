module AMS
  module Migrations
    class AnnotationMigration
      attr_accessor :assets

      FIELDS_TO_MIGRATE = [ :level_of_user_access, :minimally_cataloged, :outside_url, :special_collection, :transcript_status, :licensing_info, :playlist_group, :playlist_order, :organization, :special_collection_category, :canonical_meta_tag ]

      FIELDS_WITH_MAP = { :minimally_cataloged => :cataloging_status, :special_collection => :special_collections }

      def initialize
        # Use Assets because they are 1-to-1 with AdminData
        # and we want to use the AssetActor for indexing
        @assets = Asset.all
        @errors = []
      end

      def run
        migrate_data(assets)
        puts @errors
      end

      private

      def migrate_data(admin_data_objects)
        processed_assets = []

        assets.each do |asset|
          admin_data = asset.admin_data
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
                hot_package << anno
                admin_data.send("#{field_name}=", nil) unless FIELDS_WITH_MAP.values.include?(field_name)
                admin_data.send("#{FIELDS_WITH_MAP.key(field_name)}=", nil) if FIELDS_WITH_MAP.values.include?(field_name)
              else
                @errors << "Annotations Migration Error: Annotation invalid for AdminData object( id: #{admin_data.id.to_s}, #{field_name}: #{field_value} \n"
              end
            end
          end

          hot_package << asset if hot_package.map(&:class).include?(Annotation)
          processed_assets << hot_package if hot_package.map(&:class).include?(Asset)
        end

        processed_assets.each do |package|
          ActiveRecord::Base.transaction do
            package.map(&:save!)
          end
        end
      end
    end
  end
end

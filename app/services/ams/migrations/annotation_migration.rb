module AMS
  module Migrations
    class AnnotationMigration
      attr_accessor :admin_data_objects

      FIELDS_TO_MIGRATE = [ :level_of_user_access, :minimally_cataloged, :outside_url, :special_collections, :transcript_status, :licensing_info, :playlist_group, :playlist_order, :organization, :special_collection_category, :canonical_meta_tag ]

      FIELDS_WITH_MAP = { :minimally_cataloged => :cataloging_status, :special_collection => :special_collections }

      def initialize
        @admin_data_objects = AdminData.all
        @errors = []
      end

      def run
        migrate_data(admin_data_objects)
        puts @errors
      end

      private

      def migrate_data(admin_data_objects)
        processed_admin_data = []

        admin_data_objects.each do |admin_data|
          hot_package = []
          FIELDS_TO_MIGRATE.each do |field|
            field_value = admin_data.send(field)
            next if field_value.nil?
            next if field_value.is_a?(Array) && field_value.empty?

            # Deals with fields that don't precisely track to new annotation_type ids
            field_name = ( FIELDS_WITH_MAP.keys.include?(field) ? FIELDS_WITH_MAP[field] : field )

            if AdminData::SERIALIZED_FIELDS.include?(field_name)
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

          hot_package << admin_data if hot_package.map(&:class).include?(Annotation)
          processed_admin_data << hot_package if hot_package.map(&:class).include?(AdminData)
        end

        processed_admin_data.each do |package|
          ActiveRecord::Base.transaction do
            package.map(&:save!)
          end
        end
      end
    end
  end
end

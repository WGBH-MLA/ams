# frozen_string_literal: true

require 'dry/monads'

module Ams
  module Steps
    class CreateAapbAdminData
      include Dry::Monads[:result]

      def call(change_set)
        case change_set.model
        when AssetResource
          add_title_types(change_set)
          add_description_types(change_set)
          add_date_types(change_set)
          set_validation_status(change_set)

          save_aapb_admin_data(change_set)
        when PhysicalInstantiationResource, DigitalInstantiationResource
          save_instantiation_aapb_admin_data(change_set)
        end

        Success(change_set)
      rescue NoMethodError => err
        Failure([err.message, change_set])
      end

      private

      def find_or_create_admin_data(change_set)
        if change_set.model.admin_data_gid.present?
          change_set.admin_data_gid = change_set.model.admin_data_gid
        else
          change_set.model.admin_data_gid = change_set.admin_data_gid
        end

        change_set.model.admin_data ||= AdminData.create
        change_set.admin_data_gid ||= change_set.model.admin_data.gid
      end

      def save_aapb_admin_data(change_set)
        find_or_create_admin_data(change_set)
        set_admin_data_attributes(change_set.model.admin_data, change_set)
        change_set.model.admin_data.save!
        remove_admin_data_from_env_attributes(change_set)
        delete_removed_annotations(change_set.model.admin_data, change_set)
        set_annotations_attributes(change_set.model.admin_data, change_set)
        remove_annotations_from_env_attributes(change_set)

        !!change_set.model.admin_data
      end

      def set_admin_data_attributes(admin_data, change_set)
        admin_data_values = change_set.fields.slice(*AdminData.attributes_for_update).compact
        # If Sony Ci IDs are present, ensure there are no blank ones, such as empty strings.
        if admin_data_values.key?('sonyci_id')
          admin_data_values['sonyci_id'] = Array(admin_data_values['sonyci_id']).reject(&:blank?)
        end
        admin_data.assign_attributes(admin_data_values)
      end

      def delete_removed_annotations(admin_data, change_set)
        return if admin_data.annotations.empty?
        return if change_set.fields["annotations"].nil?
        ids_in_change_set = change_set.fields["annotations"].select{ |ann| ann["id"].present? }.map{ |ann| ann["id"].to_i }
        admin_data.annotations.each do |annotation|
          annotation.destroy unless ids_in_change_set.include?(annotation.id)
        end
      end

      def set_annotations_attributes(admin_data, change_set)
        return if change_set.fields["annotations"].nil?
        change_set.fields["annotations"].each do |annotation|
          ann = annotation.dup.respond_to?(:to_unsafe_h) ? annotation.to_unsafe_h.with_indifferent_access : annotation.dup.with_indifferent_access
          permitted_annotation = ann.extract!(*annotation_attributes)
          # Fixes an issue where manually deleting annotations sent an
          # empty annotation to the env
          next if annotation_empty?(permitted_annotation)
          # We should always have an AdminData object by this point
          permitted_annotation["admin_data_id"] = admin_data.id
          annotation["id"].present? ? update_annotation(annotation["id"], permitted_annotation) : create_annotation(permitted_annotation)
        end
      end

      def update_annotation(id, annotation)
        a = Annotation.find(id)
        annotation_attributes.each do |attr|
          if annotation[attr].present?
            a.send("#{attr}=", annotation[attr].to_s)
          elsif !annotation[attr].present? && a.send(attr).present?
            a.send("#{attr}=", annotation[attr].to_s)
          end
        end
        a.save!
      end

      def create_annotation(annotation)
        Annotation.create!(annotation)
      end

      def annotation_empty?(annotation_env)
        annotation_env.values.uniq.length == 1 && annotation_env.values.uniq.first.empty?
      end

      def remove_admin_data_from_env_attributes(change_set)
        AdminData.attributes_for_update.each { |k| change_set.fields.delete(k) }
      end

      def remove_annotations_from_env_attributes(change_set)
        # Remove anotations from ENV so that we can save the Asset
        change_set.fields.delete("annotations")
      end

      def annotation_attributes
        # removing id, created_at & updated_at from attributes
        (Annotation.attribute_names.dup - ['id', 'created_at', 'updated_at']).map(&:to_sym)
      end

      def add_title_types(change_set)
        return unless change_set.fields["titles_with_types"].present?

        title_type_service = TitleTypesService.new
        fill_attributes_from_typed_values(title_type_service, change_set, change_set.fields["titles_with_types"])
      end

      def add_description_types(change_set)
        return unless change_set.fields["descriptions_with_types"].present?

        description_type_service = DescriptionTypesService.new
        fill_attributes_from_typed_values(description_type_service, change_set, change_set.fields["descriptions_with_types"])
      end

      def add_date_types(change_set)
        return unless change_set.fields["dates_with_types"].present?

        date_type_service = DateTypesService.new
        fill_attributes_from_typed_values(date_type_service, change_set, change_set.fields["dates_with_types"])
      end

      # @param child of [AMS::TypedFieldService] type_service
      # @param [Hyrax::Actors::Environment] env
      # @param [Array] values
      def fill_attributes_from_typed_values(type_service, change_set, values)
        raise ArgumentError, 'type_service is not child of AMS::TypedFieldService' unless type_service.is_a? AMS::TypedFieldService
        types = type_service.all_ids
        types.each do |id|
          model_field = type_service.model_field(id)
          raise "Unable to find model property" unless change_set.model.respond_to?(model_field)
          change_set.fields[model_field] = get_typed_value(id, values) if typed_value_present?(values)
        end
      end

      def typed_value_present?(values)
        return false unless values
        values.first.respond_to?(:[]) && values.first['value'].present?
      end

      def get_typed_value(type, typed_values)
        typed_values.map { |v| v[:value] if v[:type] == type } .compact
      end

      def set_validation_status(change_set)
        # TODO: #all_members is currently not a method on AssetResource, so this will always return nil
        return unless change_set.model.respond_to?(:all_members)
        # Filter out Contributions from child count since they don't get included in the :intended_children_count
        # at time of import.
        # @see AAPB::BatchIngest::PBCoreXMLMapper#asset_attributes
        #
        # This is ultimately because there is a possibility that the creation of all of an Asset's
        # Contributions could be skipped, which would significantly throw off the count for comparison.
        # @see #create_or_update_contributions
        current_children_count = change_set.model.all_members.reject { |child| child.is_a?(Contribution) }.size
        intended_children_count = change_set.model.intended_children_count.to_i

        if change_set.model.intended_children_count.blank? && change_set.model.validation_status_for_aapb.blank?
          change_set.model.validation_status_for_aapb = [Asset::VALIDATION_STATUSES[:status_not_validated]]
        elsif current_children_count < intended_children_count
          change_set.model.validation_status_for_aapb = [Asset::VALIDATION_STATUSES[:missing_children]]
        else
          change_set.model.validation_status_for_aapb = [Asset::VALIDATION_STATUSES[:valid]]
        end
      end


      def save_instantiation_aapb_admin_data(change_set)
        change_set.model.instantiation_admin_data = change_set.instantiation_admin_data = find_or_create_instantiation_admin_data(change_set)
        set_instantiation_admin_data_attributes(change_set)
        change_set.model.instantiation_admin_data.save!
        remove_instantiation_admin_data_from_env_attributes(change_set)
      end

      def find_or_create_instantiation_admin_data(change_set)
        instantiation_admin_data_gid = change_set.model.instantiation_admin_data_gid || change_set.instantiation_admin_data_gid
        if instantiation_admin_data_gid
          InstantiationAdminData.find_by_gid!(instantiation_admin_data_gid)
        else
          InstantiationAdminData.create
        end
      end

      def set_instantiation_admin_data_attributes(change_set)
        instantiation_admin_data_attributes.each do |k|
          change_set.instantiation_admin_data.send("#{k}=", change_set.fields[k].to_s)
        end
      end

      def remove_instantiation_admin_data_from_env_attributes(change_set)
        instantiation_admin_data_attributes.each { |k| change_set.fields.delete(k) }
      end

      def instantiation_admin_data_attributes
        # removing id, created_at & updated_at from attributes
        (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym
      end
    end
  end
end

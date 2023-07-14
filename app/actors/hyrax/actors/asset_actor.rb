# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  module Actors
    class AssetActor < Hyrax::Actors::BaseActor

      # TODO: Create and update are exactly the same EXCEPT for the call to
      # super, which will call #create or #update of parent class. We can dry
      # this up a bit.
      def create(env)
        contributions = extract_contributions(env)
        add_title_types(env)
        add_description_types(env)
        add_date_types(env)
        set_aapb_pushable(env)

        # queue indexing if we are importing
        env.curation_concern.reindex_extent = "queue#{env.importing.id}" if env.importing
        save_aapb_admin_data(env) && super && create_or_update_contributions(env, contributions)
      end

      def update(env)
        contributions = extract_contributions(env)
        add_title_types(env)
        add_description_types(env)
        add_date_types(env)
        set_aapb_pushable(env)

        # queue indexing if we are importing
        env.curation_concern.reindex_extent = "queue#{env.importing.id}" if env.importing
        save_aapb_admin_data(env) && super && create_or_update_contributions(env, contributions)
      end

      def destroy(env)
        super && destroy_admin_data(env)
      end

      private

        def save_aapb_admin_data(env)
          env.curation_concern.admin_data = find_or_create_admin_data(env)
          set_admin_data_attributes(env.curation_concern.admin_data, env) if env.current_ability.can?(:create, AdminData)
          remove_admin_data_from_env_attributes(env)
          delete_removed_annotations(env.curation_concern.admin_data, env)
          set_annotations_attributes(env.curation_concern.admin_data, env) if env.current_ability.can?(:create, Annotation)
          remove_annotations_from_env_attributes(env)

          # Adding a Boolean return so that this method returns one for it's role in the Hyrax ActorStack
          return true if env.curation_concern.admin_data
          false
        end

        def set_admin_data_attributes(admin_data, env)
          AdminData.attributes_for_update.each do |k|
            # Some attributes are serialized on AdminData, so always send an array
            if should_empty_admin_data_value?(k, admin_data, env)
              AdminData::SERIALIZED_FIELDS.include?(k) ? admin_data.send("#{k}=", Array.new) : admin_data.send("#{k}=", "")
            elsif env.attributes[k].present?
              AdminData::SERIALIZED_FIELDS.include?(k) ? admin_data.send("#{k}=", Array(env.attributes[k])) : admin_data.send("#{k}=", env.attributes[k].to_s)
            end
          end
        end

        def should_empty_admin_data_value?(key, admin_data, env)
          key != :bulkrax_importer_id &&
          admin_data.send(key).present? &&
          !env.attributes[key].present?
        end

        def delete_removed_annotations(admin_data, env)
          return if admin_data.annotations.empty?
          return if env.attributes["annotations"].nil?
          ids_in_env = env.attributes["annotations"].select{ |ann| ann["id"].present? }.map{ |ann| ann["id"].to_i }
          admin_data.annotations.each do |annotation|
            annotation.destroy unless ids_in_env.include?(annotation.id)
          end
        end

        def set_annotations_attributes(admin_data, env)
          return if env.attributes["annotations"].nil?
          env.attributes["annotations"].each do |annotation|
            # Fixes an issue where manually deleting annotations sent an
            # empty annotation to the env
            next if annotation_empty?(annotation)
            # We should always have an AdminData object by this point
            annotation["admin_data_id"] = admin_data.id
            case annotation["id"].present?
            when true
              a = Annotation.find(annotation["id"])
              annotation_attributes.each do |attr|
                if annotation[attr].present?
                  a.send("#{attr}=", annotation[attr].to_s)
                elsif !annotation[attr].present? && a.send(attr).present?
                  a.send("#{attr}=", annotation[attr].to_s)
                end
              end
              a.save!
            when false
              a = Annotation.create!(annotation)
            end
          end
        end

        def annotation_empty?(annotation_env)
          annotation_env.values.uniq.length == 1 && annotation_env.values.uniq.first.empty?
        end

        def remove_admin_data_from_env_attributes(env)
          AdminData.attributes_for_update.each { |k| env.attributes.delete(k) }
        end

        def remove_annotations_from_env_attributes(env)
          # Remove anotations from ENV so that we can save the Asset
          env.attributes.delete("annotations")
        end

        def annotation_attributes
          # removing id, created_at & updated_at from attributes
          (Annotation.attribute_names.dup - ['id', 'created_at', 'updated_at']).map(&:to_sym)
        end

        def find_or_create_admin_data(env)
          # Don't use present? here. It is broken for some ActiveRecord objects. Maybe due to overriding getter
          # See: https://stackoverflow.com/questions/35410668/what-determines-the-return-value-of-present
          return env.curation_concern.admin_data if env.curation_concern.admin_data.is_a?(AdminData)

          admin_data = AdminData.find_by_gid(env.attributes['admin_data_gid']) if env.attributes['bulkrax_identifier'].present?
          admin_data ||= ::AdminData.create

          Rails.logger.debug "Create AdminData at #{admin_data.gid}"
          return admin_data
        end

        def destroy_admin_data(env)
          env.curation_concern.admin_data.destroy if env.curation_concern.admin_data_gid
        end

        def extract_contributions(env)
          contributors = env.attributes.delete(:contributors) || []
          # removing element where contributor is blank, as its req field
          contributors.select { |contributor| contributor unless contributor[:contributor].first.blank? }
        end

        def create_or_update_contributions(env, contributions)
          if contributions.present?
            if contributions.any? && !contributions.first["contributor"].blank?
              contributions.each do |param_contributor|
                actor ||= Hyrax::CurationConcern.actor
                # Moving contributor into Array before saving object
                param_contributor[:contributor] = Array(param_contributor[:contributor])
                param_contributor[:admin_set_id] = env.curation_concern.admin_set_id
                param_contributor[:title] = env.attributes["title"]

                if param_contributor[:id].blank?
                  param_contributor.delete(:id)
                  contributor = ::Contribution.new

                  if actor.create(Actors::Environment.new(contributor, env.current_ability, param_contributor))
                    env.curation_concern.ordered_members << contributor
                    env.curation_concern.save
                  end
                elsif (contributor = Contribution.find(param_contributor[:id]))
                  param_contributor.delete(:id)
                  actor.update(Actors::Environment.new(contributor, env.current_ability, param_contributor))
                end
              end
            end
          end
          # This method must return true
          true
        end

        def add_title_types(env)
          if env.attributes[:titles_with_types].present?
            title_type_service = TitleTypesService.new
            fill_attributes_from_typed_values(title_type_service, env, env.attributes[:titles_with_types])
            # Now that we're done with these attributes, remove them from the
            # environment to avoid errors later in the save process.
            env.attributes.delete(:titles_with_types)
          end
        end

        def add_description_types(env)
          if env.attributes[:descriptions_with_types].present?
            description_type_service = DescriptionTypesService.new
            fill_attributes_from_typed_values(description_type_service, env, env.attributes[:descriptions_with_types])

            # Now that we're done with these attributes, remove them from the
            # environment to avoid errors later in the save process.
            env.attributes.delete(:descriptions_with_types)
          end
        end

        def add_date_types(env)
          if env.attributes[:dates_with_types].present?
            date_type_service = DateTypesService.new
            fill_attributes_from_typed_values(date_type_service, env, env.attributes[:dates_with_types])

            # Now that we're done with these attributes, remove them from the
            # environment to avoid errors later in the save process.
            env.attributes.delete(:dates_with_types)
          end
        end

        # @param child of [AMS::TypedFieldService] type_service
        # @param [Hyrax::Actors::Environment] env
        # @param [Array] values
        def fill_attributes_from_typed_values(type_service, env, values)
          raise ArgumentError, 'type_service is not child of AMS::TypedFieldService' unless type_service.is_a? AMS::TypedFieldService
          types = type_service.all_ids
          types.each do |id|
            model_field = type_service.model_field(id)
            raise "Unable to find model property" unless env.curation_concern.respond_to?(model_field)
            env.attributes[model_field] = get_typed_value(id, values) if typed_value_present?(values)
          end
        end

        def typed_value_present?(values)
          return false unless values
          values.first.respond_to?(:[]) && values.first['value'].present?
        end

        def get_typed_value(type, typed_values)
          typed_values.map { |v| v[:value] if v[:type] == type } .compact
        end

        def set_aapb_pushable(env)
          if env.curation_concern.all_members.size == env.curation_concern.intended_children_count.to_i
            env.curation_concern.aapb_pushable = true
          end
        end
    end
  end
end

# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  module Actors
    class AssetActor < Hyrax::Actors::BaseActor
      def create(env)
        contributions = extract_contributions(env)
        add_title_types(env)
        add_description_types(env)
        add_date_types(env)
        save_aapb_admin_data(env) && super && create_or_update_contributions(env, contributions)
      end

      def update(env)
        contributions = extract_contributions(env)
        add_title_types(env)
        add_description_types(env)
        add_date_types(env)
        save_aapb_admin_data(env) && super && create_or_update_contributions(env, contributions)
      end

      def destory(env)
        super && destroy_admin_data(env)
      end

      private

        def save_aapb_admin_data(env)
          env.curation_concern.admin_data = find_or_create_admin_data(env)
          set_admin_data_attributes(env.curation_concern.admin_data, env) if env.current_ability.can?(:create, AdminData)
          remove_admin_data_from_env_attributes(env)
        end

        def set_admin_data_attributes(admin_data, env)
          admin_data_attributes.each do |k|
            if [:special_collection, :sonyci_id].include?(k)
              admin_data.send("#{k}=", Array(env.attributes[k]))
            else
              admin_data.send("#{k}=", env.attributes[k].to_s)
            end
          end
        end

        def remove_admin_data_from_env_attributes(env)
          admin_data_attributes.each { |k| env.attributes.delete(k) }
        end

        def admin_data_attributes
          # removing id, created_at & updated_at from attributes
          (AdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym
        end

        def find_or_create_admin_data(env)
          admin_data = if env.curation_concern.admin_data_gid.blank?
                         AdminData.create
                       else
                         AdminData.find_by_gid!(env.curation_concern.admin_data_gid)
                       end
          admin_data
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
          # This method must return true
          true
        end

        def add_title_types(env)
          title_type_service = TitleTypesService.new
          fill_attributes_from_typed_values(title_type_service, env, env.attributes[:titles_with_types])
          # Now that we're done with these attributes, remove them from the
          # environment to avoid errors later in the save process.
          env.attributes.delete(:titles_with_types)
        end

        def add_description_types(env)
          description_type_service = DescriptionTypesService.new
          fill_attributes_from_typed_values(description_type_service, env, env.attributes[:descriptions_with_types])

          # Now that we're done with these attributes, remove them from the
          # environment to avoid errors later in the save process.
          env.attributes.delete(:descriptions_with_types)
        end

        def add_date_types(env)
          date_type_service = DateTypesService.new
          fill_attributes_from_typed_values(date_type_service, env, env.attributes[:dates_with_types])

          # Now that we're done with these attributes, remove them from the
          # environment to avoid errors later in the save process.
          env.attributes.delete(:dates_with_types)
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
    end
  end
end

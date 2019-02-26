# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
module Hyrax
  module Actors
    class PhysicalInstantiationActor < Hyrax::Actors::BaseActor
      def create(env)
        save_instantiation_aapb_admin_data(env) && super
      end

      def update(env)
        save_instantiation_aapb_admin_data(env) && super
      end

      def destroy(env)
        destroy_instantiation_admin_data(env) && super
      end

      private
        def save_instantiation_aapb_admin_data(env)
          env.curation_concern.instantiation_admin_data = find_or_create_instantiation_admin_data(env)
          set_instantiation_admin_data_attributes(env.curation_concern.instantiation_admin_data, env) if env.current_ability.can?(:create, InstantiationAdminData)
          remove_instantiation_admin_data_from_env_attributes(env)
        end

        def set_instantiation_admin_data_attributes(instantiation_admin_data, env)
          instantiation_admin_data_attributes.each do |k|
            instantiation_admin_data.send("#{k}=", env.attributes[k].to_s)
          end
        end

        def remove_instantiation_admin_data_from_env_attributes(env)
          instantiation_admin_data_attributes.each { |k| env.attributes.delete(k) }
        end

        def instantiation_admin_data_attributes
          # removing id, created_at & updated_at from attributes
          (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym
        end

        def find_or_create_instantiation_admin_data(env)
          instantiation_admin_data = if env.curation_concern.instantiation_admin_data_gid.blank?
                                       InstantiationAdminData.create
                                     else
                                       InstantiationAdminData.find_by_gid!(env.curation_concern.instantiation_admin_data_gid)
                                     end
          instantiation_admin_data
        end

        def destroy_instantiation_admin_data(env)
          env.curation_concern.instantiation_admin_data.destroy if env.curation_concern.instantiation_admin_data_gid
        end
    end
  end
end

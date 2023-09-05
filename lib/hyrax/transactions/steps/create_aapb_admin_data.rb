# frozen_string_literal: true
require 'dry/monads'

module Hyrax
  module Transactions
    module Steps
      class CreateAapbAdminData
        include Dry::Monads[:result]

        def call(change_set)
          case change_set.model
          when AssetResource

          when PhysicalInstantiationResource, DigitalInstantiationResource
            change_set.instantiation_admin_data = find_or_create_instantiation_admin_data(change_set)
            set_instantiation_admin_data_attributes(change_set)
            remove_instantiation_admin_data_from_env_attributes(change_set)
          end

          Success(change_set)
        rescue NoMethodError => err
          Failure([err.message, change_set])
        end

        private

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
              change_set.instantiation_admin_data.send("#{k}=", change_set.attributes[k].to_s)
            end
          end

          def remove_instantiation_admin_data_from_env_attributes(change_set)
            instantiation_admin_data_attributes.each do |k|
              change_set.send("#{k}=", nil) if change_set.respond_to?("#{k}=")
            end
          end

          def instantiation_admin_data_attributes
            # removing id, created_at & updated_at from attributes
            (InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym
          end
      end
    end
  end
end

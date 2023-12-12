# frozen_string_literal: true

require 'dry/monads'

module Ams
  module Steps
    class HandleContributors
      include Dry::Monads[:result]

      attr_accessor :change_set, :user
      def call(change_set, user: nil)
        @change_set = change_set
        @user = user
        case change_set.model
        when AssetResource
          contributions = extract_contributions(change_set)
          create_or_update_contributions(change_set, contributions)
        end

        Success(change_set)
      rescue NoMethodError => err
        Failure([err.message, change_set])
      end

      private

      def extract_contributions(change_set)
        return [] unless change_set.input_params.has_key?(:contributors)

        contributors = change_set.input_params.delete(:contributors) || []
        contributors.select { |contributor| contributor unless contributor['contributor'].first.blank? }.map(&:with_indifferent_access)
      end

      def create_or_update_contributions(change_set, contributions)
        if contributions&.first&.[]("contributor")&.present?
          inserts = []
          destroys = []
          contributions.each do |param_contributor|
            param_contributor[:contributor] = Array(param_contributor['contributor'])
            param_contributor[:admin_set_id] = change_set['admin_set_id']
            param_contributor[:title] = change_set["title"]

            to_destroy = ActiveModel::Type::Boolean.new.cast(param_contributor['_destroy'])
            if to_destroy
              destroys << param_contributor[:id]
              next
            end


            contributor = Contribution.find(param_contributor[:id]) if param_contributor[:id].present?
            if contributor
              param_contributor.delete(:id)
              contributor.attributes.merge!(param_contributor)
              contributor_resource = Hyrax.persister.save(resource: contributor)
              Hyrax.publisher.publish('object.metadata.updated', object: contributor_resource, user: change_set.user)
              inserts << contributor_resource.id
              next
            end
            contribution_resource = Hyrax.persister.save(resource: ContributionResource.new(param_contributor.symbolize_keys))
            Hyrax.index_adapter.save(resource: contribution_resource)
            Hyrax.publisher.publish('object.deposited', object: contribution_resource, user: user)
            Hyrax::AccessControlList.copy_permissions(source: target_permissions, target: contribution_resource)
            inserts << contribution_resource.id
          end

          update_members(change_set, inserts, destroys)
        end
      end

      def update_members(change_set, inserts, destroys)
        return if inserts.empty? && destroys.empty?
        current_member_ids = change_set.member_ids.map(&:id)
        inserts = inserts - current_member_ids
        destroys = destroys & current_member_ids
        change_set.member_ids += inserts.map  { |id| Valkyrie::ID.new(id) }
        change_set.member_ids -= destroys.map { |id| Valkyrie::ID.new(id) }
      end

      ##
      # @api private
      #
      # @note cache these per instance to avoid repeated lookups.
      #
      # @return [Hyrax::AccessControlList] permissions to set on created filesets
      def target_permissions
        @target_permissions ||= Hyrax::AccessControlList.new(resource: change_set)
      end
    end
  end
end

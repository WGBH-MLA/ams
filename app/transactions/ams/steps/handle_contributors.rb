# frozen_string_literal: true

require 'dry/monads'

module Ams
  module Steps
    class HandleContributors
      include Dry::Monads[:result]

      attr_accessor :change_set, :user
      def call(change_set, user: nil)
        @change_set = change_set
        @user = user || User.find_by_user_key(change_set.depositor)
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
        contrib = contributors.dup.map { |c| c.respond_to?(:to_unsafe_h) ? c.to_unsafe_h.with_indifferent_access : c.dup.with_indifferent_access }
        
        contrib.select { |contributor| contributor.values.any?(&:present?) || ActiveModel::Type::Boolean.new.cast(contributor['_destroy']) }
      end

      def create_or_update_contributions(change_set, contributions)
        return unless contributions.present?
        
        inserts = []
        destroys = []
        
        contributions.each do |param_contributor|
          if ActiveModel::Type::Boolean.new.cast(param_contributor['_destroy'])
            destroys << param_contributor[:id] if param_contributor[:id].present?
          end
        end
        
        contributions.select { |c| c["contributor"].present? && !ActiveModel::Type::Boolean.new.cast(c['_destroy']) }.each do |param_contributor|
          param_contributor[:contributor] = Array(param_contributor['contributor'])
          param_contributor[:admin_set_id] = change_set['admin_set_id']
          param_contributor[:title] = change_set["title"]
          
          contributor = Hyrax.query_service.find_by(id: param_contributor[:id]) if param_contributor[:id].present?
          if contributor
            param_contributor.delete(:id)
            contributor_attributes = contributor.attributes.merge(param_contributor.symbolize_keys)
            contributor_resource = Hyrax.persister.save(resource: ContributionResource.new(contributor_attributes))
            Hyrax.publisher.publish('object.metadata.updated', object: contributor_resource, user: user)
            inserts << contributor_resource.id
          else
            param_contributor.delete(:id)
            contribution_resource = Hyrax.persister.save(resource: ContributionResource.new(param_contributor.symbolize_keys))
            Hyrax.index_adapter.save(resource: contribution_resource)
            Hyrax.publisher.publish('object.deposited', object: contribution_resource, user: user)
            Hyrax::AccessControlList.copy_permissions(source: target_permissions, target: contribution_resource)
            inserts << contribution_resource.id
          end
        end
        
        update_members(change_set, inserts, destroys)
        destroy_contributions(destroys) if destroys.present?
      end

      def update_members(change_set, inserts, destroys)
        return if inserts.empty? && destroys.empty?
        current_member_ids = change_set.member_ids.map(&:to_s)
        inserts = inserts - current_member_ids
        destroys = destroys & current_member_ids
        change_set.member_ids += inserts.map  { |id| Valkyrie::ID.new(id) }
        change_set.member_ids -= destroys.map { |id| Valkyrie::ID.new(id) }
      end

      def destroy_contributions(ids)
        ids.each do |id|
          Hyrax.persister.delete(resource: Hyrax.query_service.find_by(id: id))
          Hyrax.index_adapter.delete(resource: SolrDocument.find(id))
        end
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

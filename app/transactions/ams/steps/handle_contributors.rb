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
        contrib.select { |contributor| contributor&.[]('contributor')&.first }
      end

      def create_or_update_contributions(change_set, contributions)
        if contributions&.first&.[]("contributor")&.present?
          inserts = []
          destroys = []
          contributions.each do |param_contributor|
            param_contributor[:contributor] = Array(param_contributor['contributor'])
            param_contributor[:admin_set_id] = change_set['admin_set_id']
            param_contributor[:title] = change_set["title"]

            # FIXME: removing members this way doesn't work. The form does not pass _destroy, it simply
            # doesn't pass the params for the contributor if it was removed. This is because the "Remove"
            # button deletes the outer HTML of the input fields.
            # Consider updating members by setting them equal to the contributors passed by params,
            # effectively removing the members that were not passed.
            # Importing / batch ingesting may handle deletion differently; verify whatever change made
            # here works with those features
            to_destroy = ActiveModel::Type::Boolean.new.cast(param_contributor['_destroy'])
            if to_destroy
              destroys << param_contributor[:id]
              next
            end

            if param_contributor[:id].present?
              contributor = Hyrax.query_service.find_by(id: param_contributor[:id])
              if contributor.is_a?(Contribution)
                param_contributor.delete(:id)
                contributor.attributes.merge!(param_contributor)
                contributor_resource = Hyrax.persister.save(resource: contributor)
                Hyrax.publisher.publish('object.metadata.updated', object: contributor_resource, user: user)
                inserts << contributor_resource.id
              else
                contribution_form = Hyrax::Forms::ResourceForm.for(contributor)
                sanitized_params = param_contributor.slice(:contributor_role, :contributor, :affiliation, :portrayal)
                contribution_form.validate(sanitized_params)
                Hyrax::Transactions::Container['change_set.apply'].call(contribution_form)
                inserts << contributor.id
              end
            else
              flat_values = param_contributor.slice(:contributor_role, :affiliation, :portrayal).values + param_contributor[:contributor]
              next if flat_values.none?(&:present?)

              contribution_attrs = param_contributor.symbolize_keys.except(:id) # IDs are blank for new records submitted by form
              contribution_resource = Hyrax.persister.save(resource: ContributionResource.new(contribution_attrs))
              Hyrax.index_adapter.save(resource: contribution_resource)
              Hyrax.publisher.publish('object.deposited', object: contribution_resource, user: user)
              Hyrax::AccessControlList.copy_permissions(source: target_permissions, target: contribution_resource)
              inserts << contribution_resource.id
            end
          end

          update_members(change_set, inserts, destroys)
        end
      end

      def update_members(change_set, inserts, destroys)
        return if inserts.empty? && destroys.empty?
        current_member_ids = change_set.member_ids.map(&:to_s)
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

# frozen_string_literal: true
require 'dry/monads'

module Hyrax
  module Transactions
    module Steps
      ##
      # Add a given `::User` as the `#creator` via a ChangeSet.
      #
      # If no user is given, simply passes as a `Success`.
      #
      # @since 3.0.0
      class SetChildTitle
        include Dry::Monads[:result]

        ##
        # @param [Hyrax::ChangeSet] change_set
        # @param [#user_key] user
        #
        # @return [Dry::Monads::Result]
        def call(change_set)
          byebug
          # change_set.creator = [user.user_key] if user.user_key

          Success(change_set)
        rescue NoMethodError => err
          Failure([err.message, change_set])
        end

        def title
          #Get parent title from solr document where title logic is defined
    
          # solr_document = ::SolrDocument.new(find_parent_object_hash) unless find_parent_object_hash.nil?
          # if(solr_document.title.any?)
          #   return [solr_document.title]
          #   []
          # end
        end
    
        def find_parent_object_hash
          if @controller.params.has_key?(:parent_id)
            return ActiveFedora::Base.search_by_id(@controller.params[:parent_id])
          elsif model.in_objects.any?
            return model.in_objects.first.to_solr
          else
            return nil
          end
        end
      end
    end
  end
end
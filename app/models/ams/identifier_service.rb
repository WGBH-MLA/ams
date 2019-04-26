require 'securerandom'

module AMS
  # IdentifierService should be mixed into AMS models that should have an
  # AMS-style ID. For instance the Asset model in app/models/asset.rb should
  # `include IdentifierService` in order to get IDs produced by this module.
  #
  # NOTE: The module should be included AFTER the Hyrax::WorkBehavior module
  # is included, because this module overrides the #assign_id method that
  # comes from including Hyrax::WorkBehavior.
  module IdentifierService
    ID_PREFIX = "cpb-aacip-"

    # mint
    # Mints a new ID for use in Fedora/Solr of new records, which is an ID that
    # has the constant ID_PREFIX prepended to a 12 character subset of a UUID.
    # @return [String] a new random ID prefixed with constant
    #  AMS::IdentifierService::ID_PREFIX that does not already exist in Solr.
    def self.mint
      begin
        new_id = ID_PREFIX + SecureRandom.uuid.tr('-', '').slice(0, 11)
      end until usable_id? new_id
      new_id
    end

    def self.usable_id?(id)
      return false unless id
      !!!ActiveFedora::SolrService.query("id:#{id}", rows: 1).first
    end

    private

      ## This overrides the default behavior, which is to ask Fedora for an id
      # @see ActiveFedora::Persistence.assign_id
      def assign_id
        AMS::IdentifierService.mint
      end
  end
end

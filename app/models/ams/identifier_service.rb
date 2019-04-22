require 'securerandom'

module AMS
  module IdentifierService
    ID_PREFIX = "cpb-aacip-"

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

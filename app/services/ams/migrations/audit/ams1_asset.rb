require 'pbcore'

module AMS
  module Migrations
    module Audit
      class AMS1Asset
        attr_reader :id

        def initialize(id)
          @id = id
        end

        def pbcore
          http_response if pbcore_description_doc_found?
        end

        def pbcore_present?
          pbcore.present?
        end

        def digital_instantiations_count
          @digital_instantiations_count ||= pbcore.present? ? parsed_pbcore.instantiations.select{ |i| i.digital.present? }.count : nil
        end

        def physical_instantiations_count
          @physical_instantiations_count ||= pbcore.present? ? parsed_pbcore.instantiations.select{ |i| i.physical.present? }.count : nil
        end

        def essence_tracks_count
          @essence_tracks_count ||= pbcore.present? ? parsed_pbcore.instantiations.map{ |i| i.essence_tracks }.count : nil
        end

        private

        def http_response
          @http_response ||= parse_pbcore_url.read(read_timeout: 240, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
        end

        def parsed_pbcore
          @parsed_pbcore ||= PBCore::DescriptionDocument.parse(pbcore)
        end

        def pbcore_description_doc_found?
          http_response =~ /pbcoreDescriptionDocument/
        end

        def short_id
          id.gsub(/cpb-aacip./, '').gsub(/[^a-zA-Z0-9\/\-\_]/, '')
        end

        def parse_pbcore_url
          URI.parse("https://ams.americanarchive.org/xml/pbcore/key/b5f3288f3c6b6274c3455ec16a2bb67a/guid/#{short_id}")
        end
      end
    end
  end
end

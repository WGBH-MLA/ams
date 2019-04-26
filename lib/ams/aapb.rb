require 'httparty'

module AMS
  # Module for communicating with the AAPB website.
  module AAPB
    class << self
      def host
        ENV.fetch('AAPB_HOST', 'http://americanarchive.org')
      end

      def get(*url_args)
        HTTParty.get(make_url(*url_args))
      end

      def head(*url_args)
        HTTParty.head make_url(*url_args)
      end

      def reachable?
        !!head
      rescue SocketError
        false
      end

      private

        def make_url(*url_args)
          url_args.unshift host
          URI.join(*url_args)
        end
    end
  end
end

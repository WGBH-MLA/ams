require 'httparty'

module AMS
  # Module for communicating with the AAPB website.
  module AAPB
    class << self
      def production
        'americanarchive.org'
      end

      def demoduction
        'demo.aapb.wgbh-mla.org'
      end

      def get(host, *url_args)
        HTTParty.get make_url(host, *url_args)
      end

      def head(host, *url_args)
        HTTParty.head make_url(host, *url_args)
      end

      def reachable?(host)
        !!head(host)
      rescue OpenSSL::SSL::SSLError
        # if destination host's ssl expired, thats fine
        true
      rescue SocketError, Errno::ECONNREFUSED
        false
      end

      private
        def make_url(host, *url_args)
          # HEAD check requires http://, while ssh requires it naught! joining them like this because URI#join messes up //
          url_args.unshift('https://' + host)
          URI.join(*url_args)
        end
    end
  end
end

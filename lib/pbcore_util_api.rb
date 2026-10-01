require 'faraday'
require 'faraday/multipart'
require 'active_support/core_ext/hash/indifferent_access'

module PBCoreUtilAPI
  class Client

    REQUIRED_CONFIG = [:base_url].freeze

    attr_reader :config

    # Initializes the client with configuration options.
    # The configuration can be provided directly as a hash or loaded from a YAML file.
    # 
    def initialize(config_file=nil, **config_params)
      config_from_file = config_file ? YAML.load_file(config_file).with_indifferent_access : {}
      @config = config_from_file.merge(config_params).with_indifferent_access

      valiate_config!
    end

    def convert_xml_to_json_file(file)
      response = conn.post('convert/xml-to-json-file') do |req|
        req.headers['Content-Type'] = 'multipart/form-data'
        req.body = { file: Faraday::Multipart::FilePart.new(file, 'application/xml') }
      end
      parse_response(response)
    end

    private

      def conn
        @conn ||= Faraday.new(url: config[:base_url]) do |faraday|
          faraday.request :url_encoded
          faraday.request :multipart
          faraday.response :logger, nil, { headers: false, log_level: :debug }
          faraday.adapter Faraday.default_adapter
        end
      end

      def parse_response(response)
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise "Error parsing response: #{e.message}"
      end


      def valiate_config!
        missing_keys = REQUIRED_CONFIG.select { |key| config.fetch(key, '').empty? }
        unless missing_keys.empty?
          raise ArgumentError.new("Missing required configuration keys: #{missing_keys.join(', ')}")
        end
      end
  end
end

require 'dry-schema'

module AMS
  module CsvExportExtension
    CONFIG_FILE = File.expand_path('../../../../config/csv_export.yml', __FILE__)

    def self.extended(document)
      document.will_export_as(:csv, "application/csv")
    end

    # MODULE METHODS
    class << self

      def export_config(export_type)
        export_type = export_type.to_s
        raise "No CSV export with name: '#{export_type}' is defined in #{CONFIG_FILE}; available exports are '#{export_types}'" unless export_types.include?(export_type)
        config[:exports].detect { |export_config| export_config[:type] == export_type }
      end

      def export_types
        config[:exports].map { |export_config| export_config[:type] }
      end

      def fields_for(export_type)
        field_configs_for(export_type).map { |field_config| field_config[:name] }
      end

      def field_configs_for(export_type)
        export_config(export_type)[:fields]
      end

      private

        def config_schema
          @config_schema ||= Dry::Schema.Params do
            required(:exports).array(:hash) do
              required(:type).filled(:string)
              required(:fields).value(:array, min_size?: 1).each do
                hash do
                  required(:name)
                  optional(:method)
                end
              end
            end
          end
        end


        # Loads CSV Export config from file, validates it, and returns a hash
        # of the config.
        # @raise [RuntimeError] when config file does not exist.
        # @raise [RuntimeError] when config file causes a YAML parsing error.
        # @return [Hash] the CSV export configuration keyed by export.
        def config
          @config ||= config_schema.call(YAML.load_file(CONFIG_FILE)).to_h
        rescue Errno::ENOENT => e
          raise "No CSV export config file found at '#{CONFIG_FILE}'"
        rescue Psych::SyntaxError => e
          raise "Invalid CSV export config file '#{CONFIG_FILE}'. #{e.class}: #{e.message}"
        end
    end

    def export_as_csv(export_type)
      csv_row_for(export_type).join(",")
    end

    def csv_row_for(export_type)
      CsvExportExtension.field_configs_for(export_type).map do |field_config|
        method = field_config[:method] || field_config[:name].gsub(/\s+/, '_').downcase.to_sym
        value = send(method)
        # Values may be single-valued or multi-valued (an Array), but the output
        # for CSV should always be a string, so here we ensure the value is a
        # string and, if multi-valued, is joined together with a ; delimiter.
        Array(value).map(&:to_s).join('; ')
      end
    end
  end
end

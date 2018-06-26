module Importer
  # rubocop:disable Metrics/ClassLength
  class CSVParser
    class ParserError < StandardError
    end
    include Enumerable
    attr_reader :email

    def initialize(content)
      @content = content.sub(/\A\W+/, '')
      # Read email from first row
      read_email
    end

    # @yieldparam attributes [Hash] the attributes from one row of the file
    def each(&_block)
      headers = nil
      CSV.parse(@content, encoding: 'iso-8859-1:utf-8') do |row|
        if headers
          # we already have headers, so this is not the first row.
          yield attributes(headers, row)
        else
          # Read headers
          headers = validate_headers(row)
        end
      end
    end

    private

      def email_row?(row)
        email_re = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        filled = row.select(&:present?)
        filled.length == 1 && filled.first.match?(email_re)
      end

      def read_email
        row = CSV.parse(@content).first
        @email = row.first if email_row?(row)
      end

      def validate_headers(row)
        row.compact!
        difference = (row - valid_headers)
        return nil if email_row?(difference)

        raise ParserError, "Invalid headers: #{difference.join(', ')}" if difference.present?

        required_headers(row)
        row
      end

      def required_headers(row)
        required_fields = %w[pbcore_path]
        # required_fields = Hyrax::ImageForm.required_fields.map(&:to_s) + ['file', 'type']
        missing = required_fields.reject { |item| row.include?(item) }
        raise ParserError, "Required headers missing: #{missing.join(', ')}" if missing.present?
      end

      def valid_headers
        %w[id accession_number pbcore_path admin_set_id]
      end

      # def collection_headers
      #   %w[collection_id collection_title collection_accession_number]
      # end

      def attributes(headers, row)
        {}.tap do |processed|
          headers.each_with_index do |header, index|
            extract_field(header, row[index], processed)
          end
        end
      end

      # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      def extract_field(header, val, processed)
        return if val.blank?
        case header
        when 'pbcore_path', 'accession_number', 'id', 'admin_set_id'
          # single valued fields
          processed[header.to_sym] = val
        # when /^(created|issued|date_copyrighted|date_valid)_(.*)$/
        #   key = "#{Regexp.last_match(1)}_attributes".to_sym
        #   # TODO: this only handles one date of each type
        #   processed[key] ||= [{}]
        #   update_date(processed[key].first, Regexp.last_match(2), val)
        # when /^collection_(.*)$/
        #   processed[:collection] ||= {}
        #   update_collection(processed[:collection], Regexp.last_match(1), val)
        # else
        #   last_entry = Array(processed[header.to_sym]).last
        #   if last_entry.is_a?(Hash) && !last_entry[:name]
        #     update_typed_field(header, val, processed)
        #   else
        #     extract_multi_value_field(header, val, processed)
        #   end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

      # def extract_multi_value_field(header, val, processed, key = nil)
      #   key ||= header.to_sym
      #   processed[key] ||= []
      #   val = val.strip
      #   # Workaround for https://jira.duraspace.org/browse/FCREPO-2038
      #   val.delete!("\r")
      #   processed[key] << (looks_like_uri?(val) && Image.controlled_properties.include?(header.to_sym) ? RDF::URI(val) : val)
      # end
      #
      # def looks_like_uri?(str)
      #   str =~ %r{^https?://}
      # end
      #
      # # Fields that have an associated *_type column
      # def update_typed_field(header, val, processed)
      #   if header.match?(type_header_pattern)
      #     stripped_header = header.gsub('_type', '')
      #     processed[stripped_header.to_sym] ||= []
      #     processed[stripped_header.to_sym] << { type: val }
      #   else
      #     fields = Array(processed[header.to_sym])
      #     fields.last[:name] = val
      #   end
      # end
      #
      # def update_collection(collection, field, val)
      #   val = [val] unless %w[admin_policy_id id].include? field
      #   collection[field.to_sym] = val
      # end
      #
      # def update_date(date, field, val)
      #   date[field.to_sym] ||= []
      #   date[field.to_sym] << val
      # end
  end
  # rubocop:enable Metrics/ClassLength
end

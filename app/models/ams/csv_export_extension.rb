module AMS
  module CsvExportExtension
    CSV_FIELDS = {:GUID=>:id,:Title=>:title,:dates=>:all_dates,:producing_organization=>:producing_organization,
                  :description=>:description,:level_of_user_access=>:level_of_user_access,:minimally_cataloged=>:minimally_cataloged,
                  :holding_organization =>:holding_organization_ssim}.freeze

    def self.get_csv_header
      return CSV.generate do |csv|
        header_row = []
        CSV_FIELDS.each do |label,responder|
          header_row << label
        end
        csv << header_row
      end
    end

    def self.extended(document)
      document.will_export_as(:csv, "application/csv")
    end

    def export_as_csv
      return CSV.generate do |csv|
        row = []
        CSV_FIELDS.each do |csv_field,responder|
          val = self.send(responder)
          val = val.join("; ") if val.class == Array
          row << val
        end
        csv << row
      end
    end
  end
end
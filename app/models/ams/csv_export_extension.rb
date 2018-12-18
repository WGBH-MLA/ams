module AMS
  module CsvExportExtension
    CSV_FIELDS = {'asset' =>
                    { :GUID=>:id,:title=>:title,:dates=>:all_dates,:producing_organization=>:producing_organization, :description=>:description,:level_of_user_access=>:level_of_user_access,:minimally_cataloged=>:minimally_cataloged, :holding_organization =>:holding_organization_ssim}.freeze,
                  'digital_instantiation' =>
                    { :asset_id=>:id,:digital_instantiation_id=>:id,:local_identifier=>:local_instantiation_identifer,:media_type=>:media_type,:generations=>:generations,:duration=>:duration,:file_size=>:file_size }.freeze,
                  'physical_instantiation' =>
                    { :asset_id=>:id,:physical_instantiation_id=>:id,:local_identifier=>:local_instantiation_identifer,:holding_organization=>:holding_organization,:physical_format=>:format,:title=>:title,:date=>:all_dates,:digitized=>:digitized? }.freeze,
                  }

    ASSET_DATA_FOR_INSTANTIATION_ROW = [ :asset_id, :titles, :digitized, :date ]

    def self.get_csv_header(object)
      return CSV.generate do |csv|
        header_row = []
        CSV_FIELDS[object].each do |label,responder|
          header_row << label
        end
        csv << header_row
      end
    end

    def self.extended(document)
      document.will_export_as(:csv, "application/csv")
    end

    def export_as_csv(object)
      return CSV.generate do |csv|
        case object
        when 'asset'
          row = []
          CSV_FIELDS['asset'].each do |csv_field,responder|
            val = self.send(responder)
            val = val.join("; ") if val.respond_to?(:each)
            row << val
          end
          csv << row
        when 'digital_instantiation'
          member_ids = self["member_ids_ssim"]
          digital_instantiation_docs = member_ids.map{ |id| SolrDocument.find(id) }.select{ |inst| inst["has_model_ssim"].include?("DigitalInstantiation")}
          digital_instantiation_docs.each do |doc|
            csv << construct_instantiation_row(object,doc)
          end
        when 'physical_instantiation'
          member_ids = self["member_ids_ssim"]
          digital_instantiation_docs = member_ids.map{ |id| SolrDocument.find(id) }.select{ |inst| inst["has_model_ssim"].include?("PhysicalInstantiation")}
          digital_instantiation_docs.each do |doc|
            csv << construct_instantiation_row(object,doc)
          end
        end
      end
    end

    private

    def construct_instantiation_row(object, doc)
      row = []
      CSV_FIELDS[object].each do |csv_field,responder|
        val = nil
        if ASSET_DATA_FOR_INSTANTIATION_ROW.include?(csv_field)
          val = self.send(responder)
        else
          val = doc.send(responder)
        end
        val = val.join("; ") if val.class == Array
        row << val
      end
      row
    end
  end
end
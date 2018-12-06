require 'rails_helper'

RSpec.describe AMS::CsvExportExtension do
  subject { extension }
  let(:extension) { described_class }
  let(:asset_with_physical_instantiation) { create(:asset, :with_physical_instantiation) }


  describe ".get_csv_header" do
    it "gets the expected headers" do
      expected_headers =  { 'asset' => extension.get_csv_header('asset'),
                            'digital_instantiation' => extension.get_csv_header('digital_instantiation'),
                            'physical_instantiation' => extension.get_csv_header('physical_instantiation')
                          }

      AMS::CsvExportExtension::CSV_FIELDS.each do |object, values|
        values.keys.each do |key|
          expect(expected_headers[object]).to include(key.to_s)
        end
      end
    end
  end

  describe ".export_as_csv" do
    describe "exports the expected data" do
      it "for an asset report" do
        solr_doc = SolrDocument.find(asset_with_physical_instantiation.id)
        data = solr_doc.export_as_csv('asset')

        AMS::CsvExportExtension::CSV_FIELDS['asset'].each do |csv_field,responder|
          val = solr_doc.send(responder)
          val = val.join("; ") if val.class == Array
          expect(data).to include val.to_s
        end
      end

      describe "for a physical instantiation report" do
        let(:asset_solr_doc) { solr_doc = SolrDocument.find(asset_with_physical_instantiation.id) }
        let(:physical_instantiation_solr_doc) { SolrDocument.find(asset_solr_doc["member_ids_ssim"][0]) }

        it 'reports asset data from the asset' do
          data = asset_solr_doc.export_as_csv('physical_instantiation')

          AMS::CsvExportExtension::CSV_FIELDS['physical_instantiation'].each do |csv_field,responder|
            if csv_field == :asset_id || csv_field == :titles || csv_field == :digitized
              val = asset_solr_doc.send(responder)
              val = val.join("; ") if val.class == Array
              expect(data).to include val.to_s
            end
          end
        end

        it 'reports physical_instantiation data from the physical instantiation' do
          data = asset_solr_doc.export_as_csv('physical_instantiation')

          AMS::CsvExportExtension::CSV_FIELDS['physical_instantiation'].each do |csv_field,responder|
            unless csv_field == :asset_id || csv_field == :titles || csv_field == :digitized
              val = physical_instantiation_solr_doc.send(responder)
              val = val.join("; ") if val.class == Array
              expect(data).to include val.to_s
            end
          end
        end
      end
    end
  end
end
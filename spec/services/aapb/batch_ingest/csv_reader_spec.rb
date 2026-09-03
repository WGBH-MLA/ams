require 'rails_helper'

RSpec.describe AAPB::BatchIngest::CSVReader do
  let(:reader_options) { Hyrax::BatchIngest.config.ingest_types[ingest_type].reader_options }
  subject { described_class.new(csv.path, reader_options) }

  context 'for ingest type aapb_csv_reader_1' do
    let(:ingest_type) { :aapb_csv_reader_1 }

    context ', when input CSV contains Contributor data' do
      let(:csv) {
        create(:csv, rows: csv_rows, headers: csv_headers)
      }

      let(:asset_headers) {
        [
          "Asset",
          "Asset.program_title",
          "Asset.program_description"
        ]
      }
  
      let(:contrib_headers) {
        [
          "Contribution",
          "Contribution.contributor",
          "Contribution.contributor_role",
          "Contribution.contributor_role_annotation",
          "Contribution.affiliation",
          "Contribution.affiliation_annotation",
          "Contribution.portrayal",
          "Contribution.annotation",
          "Contribution.start_time",
          "Contribution.end_time",
          "Contribution.time_annotation"
        ]
      }
  
      let(:csv_headers) {
        [
          asset_headers,
          # Repeat the Contribution headers for the max number of Contributors we have in contrib_csv_rows
          contrib_headers * contrib_csv_rows.map{ |row| row.count }.max
        ].flatten
      }
  
      # A list of attributes for an AssetResource model used for generating test CSV rows.
      let(:asset_csv_rows) {
        attributes_for_list(:asset_resource, 2)
      }
  
      let(:contrib_csv_rows) {
        asset_csv_rows.count.times.map do |i|
          attributes_for_list(:contribution_resource, 2)
        end
      }
  
      # Uses built (not saved) AssetResource and ContributionResource instances to
      # build CSV rows for a CSV file for testing the CSV ingest.
      let(:csv_rows) {
        asset_csv_rows.map.with_index do |ar, i|
          [
            "",
            ar[:program_title].first,
            ar[:program_description].first,
            contrib_csv_rows[i].map do |contrib_vals|
              [
                "",
                contrib_vals[:contributor].first,
                contrib_vals[:contributor_role],
                contrib_vals[:contributor_role_annotation],
                contrib_vals[:affiliation],
                contrib_vals[:affiliation_annotation],
                contrib_vals[:portrayal],
                contrib_vals[:annotation],
                contrib_vals[:start_time],
                contrib_vals[:end_time],
                contrib_vals[:time_annotation]
              ]
            end
          ].flatten
        end      
      }
  
      describe ', method #batch_items' do
        let(:batch_items) { subject.batch_items }
  
        it ', returns BatchItem instances with full Contribution data' do
            
        end
  
        it ', returns BatchItem instances with partial Contribution data' do
        end
  
        context ', when input CSV contains rows with emtpy cells for Contributor' do
  
  
          let(:contribution_data) { subject.batch_items.map { |batch_item|
            JSON.parse(batch_item.source_data)['Contribution']
          }}
  
          it ', does not instantiate a BatchItem when Contribution data is empty' do
            expect(batch_items.count).to eq (csv_rows.count - empty_csv_rows.count)
          end
        end
      end
    end
  end
end

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

      # Specify which ingest fields that will end up in the CSV file for an Assets.
      let(:asset_ingest_fields) {
        [
          :program_title,
          :program_description
        ]
      }
  
      # Specify which ingest fields that will be a part of the CSV for Contributions
      let(:contrib_ingest_fields) {
        [
          :contributor,
          :contributor_role,
          :contributor_role_annotation,
          :affiliation,
          :affiliation_annotation,
          :portrayal,
          :annotation,
          :start_time,
          :end_time,
          :time_annotation
        ]
      }

      # A list of headers for AssetResource data based on the ingest fields specified for this test.
      # The list is prepended with "Asset" marking the beginning of Asset fields as required by CSV ingester.
      # All other headers for AssetResource data are prepended with "Asset."
      let(:asset_headers) {
        ["Asset"] + asset_ingest_fields.map { |field| "Asset.#{field}" }
      }

      # A list of headers for ContributionResource data based on the ingest fields specified for this test.
      # The list is prepended with "Contribution" marking the beginning of Contribution fields as required by CSV ingester.
      # All other headers for ContributionResource data are prepended with "Contribution."
      # The list is repeated for each ContributionResource data row that will be generated for each AssetResource row in the CSV file.
      let(:contrib_headers) {
        single_contrib_headers = ["Contribution"] + contrib_ingest_fields.map { |field| "Contribution.#{field}" }
        max_contribs = contrib_data.map(&:count).max
        single_contrib_headers * max_contribs
      }
  
      let(:csv_headers) {
        asset_headers + contrib_headers
      }
  
      # An array of hashes containing test data for an AssetResource model used
      # for generating test CSV rows.
      let(:asset_data) {
        attributes_for_list(:asset_resource, 2).map do |attrs|
          attrs.slice(*asset_ingest_fields)
        end
      }
  
      # A 2-D array of hashes containing test data for an ContributionResource
      # model used for generating test CSV rows.
      # The first set of indices represent the rows in the CSV, i.e. the Assets.
      let(:contrib_data) {
        asset_data.map do |i|
          attributes_for_list(:contribution_resource, 2).map do |attrs|
            # Map the contributor name field (called just 'contributor') to the
            # first value of the model instance, since it is currently (and
            # incorrectly) set to be multi-valued.
            attrs[:contributor] = attrs[:contributor].first
            
            # Slice out the values we need to make a row of data given the
            # specified CSV fields we are testing.
            attrs.slice(*contrib_ingest_fields)
          end
        end
      }
  
      let(:csv_rows) {
        asset_data.map.with_index do |asset_attrs, i|
          [
            "",
            asset_attrs.values,
            contrib_data[i].map do |contrib_attrs|
              [""] + contrib_attrs.values
            end
          ].flatten
        end      
      }
  
      describe ', method #batch_items' do
        # We are testing the #batch_items method, but are only interested in the source_data,
        # which is a JSON string. So we parse it into a hash for easier testing.
        let(:batch_items_source_data) {
          subject.batch_items.map do |batch_item|
            # Use with indiffernt access here. The parsed json will have string
            # keys And they are symbols from the factories and everywhere else,
            # it's the data that matters, not the key type.
            JSON.parse(batch_item.source_data).with_indifferent_access
          end
        }
  
        it ', returns a BatchItem per CSV row' do
          expect(batch_items_source_data.count).to eq csv_rows.count
        end

        it ', returns BatchItem instances with all the Asset data for all assets' do
          asset_data.each.with_index do |asset_attrs, row_num|
            source_data = batch_items_source_data[row_num]
            asset_attrs.each do |field, test_val|
              expect(source_data['Asset']).to include(field => test_val)
            end
          end
        end
        
        it ', returns BatchItem instances with all the Contribution data for all contributors' do
          contrib_data.each.with_index do |contribs, row_num|
            source_data = batch_items_source_data[row_num]['Asset']['contributors']
            contribs.each_with_index do |contrib_attrs, contrib_num|
              contrib_attrs.each do |field, test_val|
                if field == :contributor
                  # The contributor is multi-valued, although should not be.
                  # Test for it being an array of one value.
                  expect(source_data[contrib_num]).to include(field => [test_val])
                else
                  expect(source_data[contrib_num]).to include(field => test_val)
                end
              end
            end
          end
        end
  
        context ', when one of the Contributors has only partial data' do

          before do
            # Remove the value for contributor_role_annotation from the first contrib of the first asset
            # in the input data, and test that it does not appear in the BatchItem source_data for that asset.
            contrib_data[0][0][:contributor_role_annotation] = ""
          end

          it ', does not create BatchItem Contribution data for the missing fields' do
            batch_items_source_data.each.with_index do |source_data, row_num|
              source_data['Asset']['contributors'].map.with_index do |contrib_source_data, contrib_num|
                  contrib_data[row_num][contrib_num].each do |field, test_val|
                    if field == :contributor
                      # The contributor is multi-valued, although should not be.
                      # Test for it being an array of one value.
                      expect(contrib_source_data[field]).to eq [test_val]
                    elsif field == :contributor_role_annotation && row_num == 0 && contrib_num == 0
                      expect(contrib_source_data.keys).not_to include(field.to_s)
                    else
                      expect(contrib_source_data[field]).to eq test_val
                    end
                  end
                end
            end
          end
        end
  
        context ', when input CSV contains rows with emtpy cells for Contributor' do

          before do
            # Remove all contributors from first asset in input data
            contrib_data[0] = []
          end
  
          it ', does not create BatchItem Contribution data is empty' do
            contrib_data.each.with_index do |contribs, row_num|
              batch_item_contribs = batch_items_source_data[row_num]['Asset']['contributors']
              if row_num == 0
                batch_item_contribs.each do |batch_item_contrib|
                  expect(batch_item_contrib['contributor']).to eq []
                  expect(batch_item_contrib.keys).to eq ["contributor"]
                end
              else
                batch_item_contribs.each_with_index do |batch_item_contrib, contrib_num|
                  contribs[contrib_num].each do |field, test_val|
                    if field == :contributor
                      # Again, the contributor is multi-valued, although should not be.
                      # Test for it being an array of one value.
                      expect(batch_item_contrib[field]).to eq [test_val]
                    else
                      expect(batch_item_contrib[field]).to eq test_val
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe AMS::CsvExportExtension do
  # Create a test Asset, with a physical instantiation and a digital
  # instantiation and an Annotation for level_of_user_access.
  let!(:digital_instantiation) do
    create(:digital_instantiation,
      # :with_instantiation_admin_data param expects a Global ID.
      with_instantiation_admin_data: create(:instantiation_admin_data).gid
    )
  end
  let!(:physical_instantiation) { create(:physical_instantiation) }
  let!(:asset) do
    create(:asset,
      ordered_members: [ digital_instantiation, physical_instantiation ],
      with_admin_data: create(:admin_data,
        annotations: [
          build(:annotation,
            annotation_type: 'level_of_user_access',
            value: "Online Reading Room"
          ),
          build(:annotation,
            annotation_type: 'cataloging_status',
            value: 'Minimally Cataloged'
          ),
          build(:annotation,
            annotation_type: 'organization',
            value: 'WGBH'
          )
        ]
      ).gid # :with_admin_data expects the GlobalID, not the object itself.
    )
  end

  describe "#csv_row_for(:asset)" do
    context 'when the SolrDocument represents an Asset' do
      let(:solr_doc) { SolrDocument.find(asset.id) }
      let(:actual_csv_row) { solr_doc.csv_row_for(:asset) }
      let(:expected_csv_row) {
        [
          solr_doc.id,
          solr_doc.local_identifier.join('; '),
          solr_doc.title.join('; '),
          solr_doc.dates,
          solr_doc.producing_organization.join('; '),
          solr_doc.description.join('; '),
          solr_doc.level_of_user_access.first,
          solr_doc.cataloging_status.first,
          solr_doc.organization.join('; ')
        ]
      }

      it 'returns Asset data as a CSV row' do
        expect(actual_csv_row).to eq expected_csv_row
        # Expect every field to have a value.
        actual_csv_row.each.with_index do |val, i|
          expect(val.to_s.strip).not_to be_empty, "Expected field #{i+1} of CSV row to not be empty"
        end
      end
    end
  end

  describe "#csv_row_for(:digital_instantiation)" do
    context 'when the SolrDocument represents an DigitalInstantiation' do
      let(:solr_doc) { SolrDocument.find(digital_instantiation.id) }
      let(:actual_csv_row) { solr_doc.csv_row_for(:digital_instantiation) }
      let(:expected_csv_row) {
        [
          solr_doc.parent_asset_id,
          solr_doc.id,
          solr_doc.local_instantiation_identifier.join('; '),
          solr_doc.md5.first,
          solr_doc.media_type.join('; '),
          solr_doc.generations.join('; '),
          solr_doc.duration.first,
          solr_doc.file_size.first
        ]
      }

      it 'returns Asset data as a CSV row' do
        expect(actual_csv_row).to eq expected_csv_row
        # The objects we ceated above should produce a CSV with a value in every
        # column, so check that here.
        actual_csv_row.each.with_index do |val, i|
          expect(val.to_s.strip).not_to be_empty, "Expected field #{i+1} of CSV row to not be empty"
        end
      end
    end
  end

  describe "#csv_row_for(:physical_instantiation)" do
    context 'when the SolrDocument represents an PhysicalInstantiation' do
      let(:solr_doc) { SolrDocument.find(physical_instantiation.id) }
      let(:actual_csv_row) { solr_doc.csv_row_for(:physical_instantiation) }
      let(:expected_csv_row) {
        [
          solr_doc.parent_asset_id,
          solr_doc.id,
          solr_doc.local_instantiation_identifier.join('; '),
          solr_doc.holding_organization.join('; '),
          solr_doc.format.join('; '),
          solr_doc.title.join('; '),
          solr_doc.dates.to_s,
          solr_doc.digitized?.to_s
        ]
      }

      it 'returns Asset data as a CSV row' do
        expect(actual_csv_row).to eq expected_csv_row
        # The objects we ceated above should produce a CSV with a value in every
        # column, so check that here.
        actual_csv_row.each.with_index do |val, i|
          expect(val.to_s.strip).not_to be_empty, "Expected field #{i+1} of CSV row to not be empty"
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CatalogController, controller: true do
  describe 'GET export' do
    include Devise::Test::ControllerHelpers
    include ActiveJob::TestHelper

    after { clear_enqueued_jobs }

    # Default params for running the export. Change these in examples as
    # necessary.
    let(:object_type) { 'asset' }
    let(:format) { 'csv' }
    let(:search_params) { {} }
    let(:params) { search_params.merge(object_type: object_type) }

    before do
      # Set the queue adapter to :test so we can take advantage of
      # the #enqueued_jobs method.
      Rails.application.config.active_job.queue_adapter = :test
      # Sign in so there is a current user.
      sign_in create(:user)
    end

    context 'when number of records exceeds max limit' do
      let(:num_found) { Rails.configuration.max_export_limit + 1 }
      before do
        # Mock the 'nearest edge' that indicates the size of the export, which
        # is AMS::Export::Search::Base#num_found, called by CatalogController.
        allow_any_instance_of(AMS::Export::Search::Base).to receive(:num_found).and_return(num_found)
        get :export, params: params, format: format
      end

      it "returns the user to the search interface with a flash message" do
        expect( subject.request.flash[:alert] ).to eq "Export of size #{num_found} is too large. Max export limit is #{Rails.configuration.max_export_limit}."
        expect( subject ).to redirect_to action: :index, params: search_params
      end
    end

    context 'when number of records is < max limit, but > browswer limit' do
      let(:num_found) { Rails.configuration.max_export_to_browser_limit + 1 }
      before do
        # Mock the 'nearest edge' that indicates the size of the export, which
        # is AMS::Export::Search::Base#num_found, called by CatalogController.
        allow_any_instance_of(AMS::Export::Search::Base).to receive(:num_found).and_return(num_found)
        get :export, params: params, format: format
      end

      it 'enqueues an ExportRecordsJob, and returns the user to the search interface with a flash message' do
        expect(enqueued_jobs.last[:job]).to eq ExportRecordsJob
        expect( subject ).to redirect_to action: :index, params: search_params
        expect( subject.request.flash[:notice] ).to eq "Export job enqueued!"
      end

    end

    context 'when number of records is < browswer limit' do
      # Make up title to search on.
      let(:searchable_title) { "Pizzle Whizzle" }

      # Create some test assets with the searchable_title, physical
      # instantiations, and digital instantiations.
      let!(:asset_resources) do
        rand(1..3).times.map do
          members = create_list(:digital_instantiation_resource, rand(1..3))
          members += create_list(:physical_instantiation_resource, rand(1..3))
          create(:asset_resource, title: [ searchable_title ], members: members, visibility_setting: 'open')
        end
      end

      # Search params to search for searchable_title
      let(:search_params) { { q: searchable_title } }

      # Make the export request
      before do
        Hyrax::SolrService.commit
        get :export, params: params, format: format
      end


      context 'when the export type is CSV' do
        # Get the actual CSV data rows from the response, i.e. all rows except
        # the first (the CSV header).
        # Note: use a Set to compare results without worrying about order.
        let(:actual_csv_rows) do
          Set.new(CSV.parse(response.body).slice(1..-1))
        end

        # Get the actualy CSV header from the response.
        let(:actual_csv_header) { CSV.parse(response.body).first }

        context 'when the "object_type" param is "asset"' do
          let(:object_type) { 'asset' }

          # Get the expected CSV rows.
          # Note: use a Set to compare results without worrying about order.
          let(:expected_csv_rows) {
            Set.new.tap do |csv_rows|
              asset_resources.each do |asset_resource|
                csv_rows << SolrDocument.new(Hyrax::ValkyrieIndexer.for(resource: asset_resource).to_solr).csv_row_for(object_type)
              end
            end
          }

          # Put together the expected CSV data from the test Assets created.
          let(:expected_csv_header) { [ "Asset ID", "Local Identifier", "Title", "Dates", "Producing Organization", "Description", "Level of User Access", "Cataloging Status", "Holding Organization" ] }

          it 'sends the CSV file as a download with a clear filename and correct Content-Type' do
            expect(response.headers['Content-Disposition']).to match /attachment/
            expect(response.headers['Content-Disposition']).to match /filename="export-assets-.*\.csv"/
            expect(response.headers['Content-Type']).to match /text\/csv/
            expect(actual_csv_rows).not_to be_empty
            expect(actual_csv_rows).to eq expected_csv_rows
            expect(actual_csv_header).to eq expected_csv_header
          end
        end

        context 'when the "object_type" param is "physical_instantiation"' do
          let(:object_type) { 'physical_instantiation' }

          # Get the expected CSV rows.
          # Note: use a Set to compare results without worrying about order.
          let(:expected_csv_rows) {
            Set.new.tap do |csv_rows|
              asset_resources.map do |asset_resource|
                asset_resource.physical_instantiations.each do |physical_instantiation_solr|
                  csv_rows << physical_instantiation_solr.csv_row_for('physical_instantiation')
                end
              end
            end
          }

          # Put together the exhark_the_redis_current_nevermorepected CSV data from the test Assets created.
          let(:expected_csv_header) { ["Asset ID", "Physical Instantiation ID", "Local Instantiation Identifier", "Holding Organization", "Physical Format", "Title", "Date", "Digitized"] }

          it 'sends the CSV file as a download with a clear filename and correct Content-Type' do
            expect(response.headers['Content-Disposition']).to match /attachment/
            expect(response.headers['Content-Disposition']).to match /filename="export-physical-instantiations-.*\.csv"/
            expect(response.headers['Content-Type']).to match /text\/csv/
            expect(actual_csv_rows).not_to be_empty
            expect(actual_csv_rows).to eq expected_csv_rows
            expect(actual_csv_header).to eq expected_csv_header
          end
        end

        context 'when the "object_type" param is "digital_instantiation"' do
          let(:object_type) { 'digital_instantiation' }

          # Get the expected CSV rows.
          # Note: use a Set to compare results without worrying about order.
          let(:expected_csv_rows) {
            Set.new.tap do |csv_rows|
              asset_resources.map do |asset_resource|
                asset_resource.digital_instantiation_resources.each do |digital_instantiation_resource|
                  csv_rows << digital_instantiation_resource.csv_row_for('digital_instantiation')
                end
              end
            end
          }

          # Put together the expected CSV data from the test Assets created.
          let(:expected_csv_header) { ["Asset ID", "Digital Instantiation ID", "Local Instantiation Identifier", "MD5", "Media Type", "Generations", "Duration", "File Size"] }

          it 'sends the CSV file as a download with a clear filename and correct Content-Type' do
            expect(response.headers['Content-Disposition']).to match /attachment/
            expect(response.headers['Content-Disposition']).to match /filename="export-digital-instantiations-.*\.csv"/
            expect(response.headers['Content-Type']).to match /text\/csv/
            expect(actual_csv_rows).not_to be_empty
            expect(actual_csv_rows).to eq expected_csv_rows
            expect(actual_csv_header).to eq expected_csv_header
          end
        end
      end
    end
  end
end

require 'rails_helper'
require 'fix/delete_asset_resources'
require 'sidekiq/testing'

RSpec.describe 'Delete Asset Resources' do
  # Temporarily set ActiveJob queue adapter to :sidekiq for this test, since
  # it's an integration test that involves running ingest jobs.
  before(:all) do
    ActiveJob::Base.queue_adapter = :sidekiq
    Sidekiq::Testing.inline!
  end
  after(:all) { ActiveJob::Base.queue_adapter = :sidekiq }


  let(:pbcore_description_documents) { build_list(:pbcore_description_document, rand(2..4), :full_aapb) }
  let(:zipped_batch) { make_aapb_pbcore_zipped_batch(pbcore_description_documents) }
  let(:batch) do 
    user, admin_set = create_user_and_admin_set_for_deposit
    run_batch_ingest(
      ingest_file_path: zipped_batch,
      ingest_type: 'aapb_pbcore_zipped',
      admin_set: admin_set,
      submitter: user
    )
  end

  let(:ids) do
    batch.batch_items.map do |batch_item|
      batch_item.repo_object_id.to_s
    end
  end

  # Non-memoized helper for fetching Asset by ID.
  def asset_resource_results
    ids.map do |id|
      begin
        Hyrax.query_service.find_by(id: id)
      rescue Valkyrie::Persistence::ObjectNotFoundError
        nil
      end
    end.compact
  end

  it 'deletes the AssetResources' do
    expect(asset_resource_results.count).to be > 0
    Fix::DeleteAssetResources.new(ids: ids).run
    expect(asset_resource_results.count).to eq 0
  end
end

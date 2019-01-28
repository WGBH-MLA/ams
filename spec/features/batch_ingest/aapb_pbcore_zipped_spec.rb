require 'rails_helper'
# TODO: Need to require this in more general location.
require 'wgbh/batch_ingest'

RSpec.feature "Ingest: AAPB PBCore - Zipped" do

  context 'where batch contains valid Assets (no children)', reset_data: false do

    before :all do
      @admin_set = create(:admin_set)
      @user_role = 'TestRole'
      @user = create(:user, role_names: [@user_role])
      @permission_template = create(:permission_template, source_id: @admin_set.id)
      @permission_template_access = create(:permission_template_access, permission_template: @permission_template,
                                                                        agent_id: @user_role,
                                                                        agent_type: 'group',
                                                                        access: 'deposit')

      # login_as @user
      # TODO: move this to more generic location.
      # ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter = :inline
      zipped_batch = zip_to_tmp(File.join(fixture_path, "batch_ingest", "aapb_pbcore_zipped", "assets_only"))
      @batch = run_batch_ingest(ingest_file_path: zipped_batch,
                                ingest_type: 'aapb_pbcore_zipped',
                                admin_set: @admin_set,
                                submitter: @user)
    end

    # Reload the batch before each example.
    before { @batch.reload }

    it 'creates the correct number of batch item records' do
      expect(@batch.batch_items.to_a.count).to eq 12
    end

    it 'has a status of completed' do
      expect(@batch.status).to eq "completed"
    end

    it 'has no errors for any batch item' do
      expect(@batch.batch_items.map(&:error)).to all(be_nil)
    end

    it 'has status of "completed" for each batch item'do
      expect(@batch.batch_items.map(&:status)).to all( eq 'completed' )
    end

    it "saves Asset records" do
      @batch.batch_items.each do |batch_item|
        expect(Asset.find(batch_item.repo_object_id)).to_not be_nil
      end
    end
  end

  # TODO: Tests for invalid Assets.

end

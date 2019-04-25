require 'rails_helper'
# TODO: Need to require this in more general location.
require 'aapb/batch_ingest'

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

      # Build a list of PBCore Description Documents, keeping it pretty small to
      # avoid long ingest times.
      @pbcore_description_documents = build_list(:pbcore_description_document, rand(2..4), :full_aapb)
      @pbcore_description_documents.each do |pbcore_description_document|
        pbcore_description_document.instantiations = [
          # Add 1-3 Digital Instantiations
          build_list(:pbcore_instantiation, rand(1..3), :digital),
          # Add 1 Physical Instantiation
          build(:pbcore_instantiation, :physical)
        ].flatten

        # Add 1-3 Essence Tracks for each instantiation
        pbcore_description_document.instantiations.each do |instantiation|
          instantiation.essence_tracks = build_list(:pbcore_instantiation_essence_track, rand(1..3))
        end
      end

      zipped_batch = make_aapb_pbcore_zipped_batch(@pbcore_description_documents)

      # login_as @user
      # TODO: move this to more generic location.
      ActiveJob::Base.queue_adapter = :inline
      @batch = run_batch_ingest(ingest_file_path: zipped_batch,
                                ingest_type: 'aapb_pbcore_zipped',
                                admin_set: @admin_set,
                                submitter: @user)
    end

    # Reload the batch before each example.
    before { @batch.reload }

    it 'creates the correct number of batch item records' do
      instantiations = @pbcore_description_documents.map(&:instantiations).flatten
      physical_instantiations = instantiations.select { |i| i.physical }
      physical_instantiation_essence_tracks = physical_instantiations.map(&:essence_tracks).flatten
      # The expected number of batch items is the  number of Assets, the number
      # of Instantiations, and the number of  Essence Tracks from Physical
      # Instantiations only. A little odd, but this is just how the ingest works
      # right now.
      expected_count = @pbcore_description_documents.count \
                       + instantiations.count \
                       + physical_instantiation_essence_tracks.count
      expect(@batch.batch_items.to_a.count).to eq expected_count
    end

    it 'has a status of completed' do
      expect(@batch.status).to eq "completed"
    end

    it 'has no errors for any batch item' do
      expect(@batch.batch_items.map(&:error)).to all(be_nil)
    end

    it 'has status of "completed" for each batch item' do
      expect(@batch.batch_items.map(&:status)).to all( eq 'completed' )
    end

    it "saves all records" do
      @batch.batch_items.each do |batch_item|
        expect(ActiveFedora::Base.find(batch_item.repo_object_id)).to_not be_nil
      end
    end
  end

  # TODO: Tests for invalid Assets.

end

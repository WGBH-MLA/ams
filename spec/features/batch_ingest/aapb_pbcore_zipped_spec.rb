require 'rails_helper'
# TODO: Need to require this in more general location.
require 'aapb/batch_ingest'

RSpec.feature "Ingest: AAPB PBCore - Zipped" do

  context 'where batch contains valid Assets (no children)', reset_data: false do

    before :all do
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

      user, admin_set = create_user_and_admin_set_for_deposit
      @batch = run_batch_ingest(ingest_file_path: zipped_batch,
                                ingest_type: 'aapb_pbcore_zipped',
                                admin_set: admin_set,
                                submitter: user)

      # Reload the batch so all the child BatchItems are populated.
      @batch.reload

      # Grab the ingested objects from the BatchItem's #repo_object_id values.
      # We store in an instance var to use it more than once between tests.
      @ingested_objects = @batch.batch_items.map do |batch_item|
        ActiveFedora::Base.find(batch_item.repo_object_id.to_s)
      end
    end

    let(:expected_batch_item_count) do
      instantiations = @pbcore_description_documents.map(&:instantiations).flatten
      physical_instantiations = instantiations.select { |i| i.physical }
      physical_instantiation_essence_tracks = physical_instantiations.map(&:essence_tracks).flatten
      # The expected number of batch items is the  number of Assets, the number
      # of Instantiations, and the number of  Essence Tracks from Physical
      # Instantiations only. A little odd, but this is just how the ingest works
      # right now.
      @pbcore_description_documents.count \
        + instantiations.count \
        + physical_instantiation_essence_tracks.count
    end

    it 'creates the correct number of batch item records' do
      expect(@batch.batch_items.to_a.count).to eq expected_batch_item_count
    end

    it 'creates additional BatchItem reocrds with inherited values for child objects' do
      batch_items_by_repo_object_id = @batch.batch_items.index_by(&:repo_object_id)
      ingested_objects_by_id = @ingested_objects.index_by(&:id)
      batch_items_by_repo_object_id.each do |repo_object_id, batch_item|
        # There should be at most 1 parent work ID; assets won't have one.
        parent_work_id = ingested_objects_by_id[repo_object_id].parent_work_ids.first
        if parent_work_id
          parent_batch_item = batch_items_by_repo_object_id[parent_work_id]
          expect(batch_item.id_within_batch).to eq parent_batch_item.id_within_batch
        end
      end
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
      expect(@ingested_objects.all?).to eq true
    end
  end

  # TODO: Tests for invalid Assets.

end

require 'rails_helper'
require 'fix/change_media_type'
require 'sidekiq/testing'

RSpec.describe Fix::ChangeMediaType do
  # Temporarily set ActiveJob queue adapter to :sidekiq for this test, since
  # it's an integration test that involves running ingest jobs.
  before(:all) do
    ActiveJob::Base.queue_adapter = :sidekiq
    Sidekiq::Testing.inline!
  end
  after(:all) { ActiveJob::Base.queue_adapter = :sidekiq }

  let(:media_types) { ['Moving Image', 'Sound'] }

  let(:instantiation_generator) do
    Enumerator.new do |y|
      loop do
        y << build(
          :pbcore_instantiation,
          # Randomly choose between digital and physical instantiations
          media_type: media_types.sample,
          # Make sure there are no default AAPB identifiers
          identifiers: []
        )
      end
    end
  end

  let(:pbcore_desc_doc_generator) do
    Enumerator.new do |y|
      loop do
        y << build(:pbcore_description_document,
          :full_aapb,
          instantiations: instantiation_generator.take(rand(1..3))
        )
      end
    end
  end

  let(:pbcore_description_documents) { pbcore_desc_doc_generator.take(rand(2..4)) }
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

  def asset_resource_results
    ids.map do |id|
      begin
        Hyrax.query_service.find_by(id: id)
      rescue Valkyrie::Persistence::ObjectNotFoundError
        nil
      end
    end.compact
  end

  # Non-memoized helper getting Physical Instantiations by media type.
  # @param media_type [String] filter by media type
  # @return [Array<PBCore::Instantiation>]
  def physical_instantiations(media_type: nil)
    asset_resource_results.flat_map do |ar|
      ar.physical_instantiation_resources.select do |i|
        media_type.nil? || i.media_type == media_type
      end
    end
  end

  # Non-memoized helper for getting Digital Instantiations by media type.
  # @param media_type [String] filter by media type
  # @return [Array<PBCore::Instantiation>]
  def digital_instantiations(media_type: nil)
    asset_resource_results.flat_map do |ar|
      ar.digital_instantiation_resources.select do |i|
        media_type.nil? || i.media_type == media_type
      end
    end
  end

  # Non-memoized helper getting all instantiations
  # @param media_type [String] filter by media type
  # @return [Array<PBCore::Instantiation>]
  def instantiations(media_type: nil)
    physical_instantiations(media_type: media_type) + digital_instantiations(media_type: media_type)
  end

  describe '.run' do
    subject { described_class.new(ids: ids, media_type: media_type, inst_type: inst_type) }

    context 'when changing to Moving Image' do
      # Setting media_types controls which will be used in test data generation.
      # Set it to "Sound" so that we can change it to "Moving Image".
      let(:media_types) { ['Sound'] }
      
      # media_type is what we are changing to
      let(:media_type) { 'Moving Image' }

      context 'for Digital Instantiations' do
        let(:inst_type) { :digital }
        it 'changes the media type to "Moving Image" for all Digital Instantiations' do
          expect(digital_instantiations(media_type: 'Moving Image')).to be_empty
          subject.run
          expect(digital_instantiations(media_type: 'Moving Image')).to eq digital_instantiations
        end
      end

      context 'for Physical Instantiations' do
        let(:inst_type) { :physical }
        it 'changes the media type to "Moving Image" for all Physical Instantiations' do
          expect(physical_instantiations(media_type: 'Moving Image')).to be_empty
          subject.run
          expect(physical_instantiations(media_type: 'Moving Image')).to eq physical_instantiations
        end
      end

      context 'for both instantiaions' do
        let(:inst_type) { :both }
        it 'changes the media type to "Moving Image" for all instantiations' do
          expect(instantiations(media_type: 'Moving Image')).to be_empty
          subject.run
          expect(instantiations(media_type: 'Moving Image')).to eq instantiations
        end
      end
    end
  end

  context 'when changing to Sound' do
    # Setting media_types controls which will be used in test data generation.
    # Set it to "Sound" so that we can change it to "Moving Image".
    let(:media_types) { ['Moving Image'] }
    
    # media_type is what we are changing to
    let(:media_type) { 'Sound' }

    context 'for Digital Instantiations' do
      let(:inst_type) { :digital }
      it 'changes the media type to "Sound" for all Digital Instantiations' do
        expect(digital_instantiations(media_type: 'Sound')).to be_empty
        subject.run
        expect(digital_instantiations(media_type: 'Sound')).to eq digital_instantiations
      end
    end

    context 'for Physical Instantiations' do
      let(:inst_type) { :physical }
      it 'changes the media type to "Sound" for all Physical Instantiations' do
        expect(physical_instantiations(media_type: 'Sound')).to be_empty
        subject.run
        expect(physical_instantiations(media_type: 'Sound')).to eq physical_instantiations
      end
    end

    context 'for both instantiaions' do
      let(:inst_type) { :both }
      it 'changes the media type to "Sound" for all instantiations' do
        expect(instantiations(media_type: 'Sound')).to be_empty
        subject.run
        expect(instantiations(media_type: 'Sound')).to eq instantiations
      end
    end
  end
end

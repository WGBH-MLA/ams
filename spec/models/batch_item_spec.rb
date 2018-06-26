require 'rails_helper'

RSpec.describe BatchItem, :clean, type: :model, admin_set: true do
  subject { batch.batch_items.create(accession_number: accession_number, attribute_hash: attributes, row_number: 1) }

  let(:batch_item) { subject }
  let(:submitter) { 'jqdoe@example.edu' }
  let(:job_id) { 'e5942432-cfd1-46f0-ba44-67d5fdd2b6e0' }
  let(:original_filename) { 'path/to/batch_file.csv' }
  let(:batch_location) { "file://local/path/#{original_filename}" }
  let(:batch) { Batch.create(submitter: submitter, job_id: job_id, original_filename: original_filename) }
  let(:accession_number) { SecureRandom.uuid }
  let(:common_attributes) do
    {
      accession_number: accession_number,
      admin_set_id: 'admin_set/default',
      pbcore_path: 'path/to/pbcore.xml'
    }
  end

  context 'no items' do
    it 'batch should be empty' do
      expect(batch.status).to eq('empty')
    end
  end

  context 'initialization' do
    let(:attributes) { {} }

    it { is_expected.to have_attributes(status: 'initialized') }
    it 'batch should be initialized' do
      expect(batch_item.batch.status).to eq('initialized')
    end
  end

  context 'valid item with accession number' do
    let(:attributes) { common_attributes }

    it 'completes successfully' do
      expect { batch_item.run }.to change { batch_item.status }.from('initialized').to('complete')
      expect(batch_item.batch.status).to eq('complete')
    end
  end

  context 'invalid item without pbcore_path' do
    let(:attributes) { common_attributes.reject { |k, _v| k == :pbcore_path } }

    it 'errors on :pbcore_path' do
      byebug
      batch_item.run
      expect(batch_item.status).to eq('error')
      expect(batch_item.error.keys).to eq([:pbcore_path])
      expect(batch_item.batch.status).to eq('error')
    end
  end

  context 'valid item without accession number' do
    let(:attributes) { common_attributes.reject { |k, _v| k == :accession_number } }

    it 'errors on :accession_number' do
      batch_item.run
      expect(batch_item.status).to eq('error')
      expect(batch_item.error.keys).to eq([:accession_number])
      expect(batch_item.batch.status).to eq('error')
    end
  end

  context 'invalid item without accession number' do
    let(:accession_number) { nil }
    let(:attributes) { common_attributes.reject { |k, _v| k == :pbcore_path } }

    it 'errors on both :pbcore_path and :accession_number' do
      batch_item.run
      expect(batch_item.status).to eq('error')
      expect(batch_item.error.keys).to eq([:pbcore_path, :accession_number])
      expect(batch_item.batch.status).to eq('error')
    end
  end

  context 'duplicate of already completed item' do
    let(:attributes) { common_attributes }
    let(:prior_batch) { Batch.create(submitter: submitter, job_id: job_id.reverse, original_filename: original_filename) }
    let(:prior_item) { prior_batch.batch_items.create(accession_number: accession_number, attribute_hash: attributes, row_number: 1) }

    it 'is skipped' do
      prior_item.complete!
      expect { batch_item.run }.to change { batch_item.status }.from('initialized').to('skipped')
    end
  end

  # context 'controlled property with invalid value' do
  #   let(:contributor) { ['Text M. Stringer'] }
  #   let(:attributes)  { common_attributes }
  #
  #   it 'errors on the controlled property' do
  #     batch_item.run
  #     expect(batch_item.status).to eq('error')
  #     expect(batch_item.error.keys).to eq([:contributor])
  #     expect(batch_item.batch.status).to eq('error')
  #   end
  # end
  #
  # context 'controlled property with blank value' do
  #   let(:contributor) { [''] }
  #   let(:attributes)  { common_attributes }
  #
  #   it 'does not error on the controlled property' do
  #     batch_item.run
  #     expect(batch_item.status).to eq('complete')
  #   end
  # end
  #
  # context 'controlled property with multiple invalid values' do
  #   let(:contributor) { ['Text M. Stringer', 'Ima Also Text'] }
  #   let(:attributes)  { common_attributes }
  #
  #   it 'errors on the property and reports both failures in error' do
  #     batch_item.run
  #     expect(batch_item.status).to eq('error')
  #     expect(batch_item.error.keys).to eq([:contributor])
  #     expect(batch_item.error).to include(contributor: 'Invalid format (URI expected): Text M. Stringer. Invalid format (URI expected): Ima Also Text. ')
  #   end
  # end
  #
  # context 'two controlled properties with invalid values' do
  #   let(:contributor) { ['Text M. Stringer'] }
  #   let(:creator) { ['Not A. Uri'] }
  #   let(:attributes) { common_attributes }
  #
  #   it 'errors on both properties' do
  #     batch_item.run
  #     expect(batch_item.status).to eq('error')
  #     expect(batch_item.error.keys).to eq([:contributor, :creator])
  #   end
  # end
end

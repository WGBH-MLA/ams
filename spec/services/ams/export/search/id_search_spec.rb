require 'rails_helper'

RSpec.describe AMS::Export::Search::IDSearch do
  let(:user) { create(:user) }
  let(:id_count) { 5 }
  let(:ids) { Array.new(id_count) { SecureRandom.uuid } }
  let(:model_name) { nil }
  let(:id_clause) { "+id:(#{ids.join(' OR ')})" }
  let(:has_model_clause) { "has_model_ssim:#{model_name}"}

  subject { described_class.new(ids: ids, user: user, model_name: model_name) }

  describe '#search_params[:q]' do
    it 'contains the clause to search all IDs' do
      expect(subject.search_params[:q]).to include id_clause
    end

    context 'when model name is nil' do
      it 'does not include the clause to search the model name' do
        expect(subject.search_params[:q]).not_to include has_model_clause
      end
    end

    context 'when :model_name is specified' do
      it 'includes the clause to search the model name' do
        expect(subject.search_params[:q]).to include has_model_clause
      end
    end
  end
end

require 'rails_helper'

RSpec.describe AMS::Export::Search::IDSearch do
  let(:user) { create(:user) }
  let(:ids) { Array.new(5) { SecureRandom.uuid } }
  let(:model_class_name) { nil }
  let(:id_clause) { "+id:(#{ids.join(' OR ')})" }
  let(:has_model_clause) { "has_model_ssim:#{model_class_name}"}

  subject { described_class.new(ids: ids, user: user, model_class_name: model_class_name) }

  describe '#search_params[:q]' do
    it 'contains the clause to search all IDs' do
      expect(subject.search_params[:q]).to include id_clause
    end

    context 'when model class is nil' do
      it 'does not include the clause to search the model name' do
        expect(subject.search_params[:q]).not_to include has_model_clause
      end
    end

    context 'when :model_class_name is specified' do
      let(:model_class_name) { "Foo" }
      it 'includes the clause to search the model name' do
        expect(subject.search_params[:q]).to include has_model_clause
      end
    end
  end
end

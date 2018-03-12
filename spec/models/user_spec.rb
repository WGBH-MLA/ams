require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'factory with default values' do
    let(:user) { create(:user, :guest) }
    it 'creates a User object with default values' do
      expect(user).to be_a User
      expect(user.email).to_not be_nil
      expect(user.guest).to be true
    end
  end
end

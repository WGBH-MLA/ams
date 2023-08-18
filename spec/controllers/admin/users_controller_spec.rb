require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin_user) { create(:admin_user) }

  before { sign_in admin_user }

  describe "GET #new" do
    render_views unless App.rails_5_1?
    before { get :new }

    it "returns a success response" do
      expect(response).to be_successful
    end
  end

  describe "POST #savenew" do
    let(:user_attributes) { attributes_for :user }

    it "creates a new user with valid attributes" do
      user_attributes.delete(:guest)
      post :savenew, params: { user: user_attributes }
      expect(User.where(email: user_attributes[:email]).present?).to be true
    end
  end
end

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:valid_attributes) {
    { email: 'valid_email@wgbh-mla.org', password: (0...8).map { (65 + rand(26)).chr }.join }
  }

  login_admin

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_success
    end
  end

  describe "POST #savenew" do
    it "creates a new user with valid attributes" do
      post :savenew, params: { user: valid_attributes }
      expect(User.last.email).to eq('valid_email@wgbh-mla.org')
    end
  end
end

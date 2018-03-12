require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:role) { Role.create(name: 'admin') }
  let(:user_attributes) do
    { email: 'wgbh_admin@wgbh.org', role_ids: [role.id] }
  end
  let(:user) do
    User.new(user_attributes) { |u| u.save(validate: false) }
  end

  before do
    login_as user
  end

  it 'i am admin ?' do
    expect(user).to be_a User
    expect(user.email).to_not be_nil
    expect(user.groups.include?('admin')).to be true
  end

  let(:valid_attributes) {
    { email: 'valid_email@wgbh-mla.org', password: (0...8).map { (65 + rand(26)).chr }.join }
  }

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_success
    end
  end

  describe "POST #savenew" do
    it "creates a new user with valid attributes" do
      post :savenew, params: { user: valid_attributes }
      expect(User.where(email: valid_attributes[:email]).present?).to be true
    end
  end
end
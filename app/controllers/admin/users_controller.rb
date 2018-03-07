class Admin::UsersController < ApplicationController
  before_action :authenticate_user!, :is_admin?

  # GET /admin/users/new
  def new
    @user = User.new
  end

  def savenew
    @user = User.create(user_params)
    redirect_to :root
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def is_admin?
    redirect_to root_path, notice: "Not authorized to create users." unless current_user.ability.admin?
  end
end

class Admin::UsersController < ApplicationController
  with_themed_layout 'dashboard'

  before_action :authenticate_user!, :is_admin?

  # Display admin menu list of users
  def index
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb t(:'hyrax.admin.users.index.title'), hyrax.admin_users_path
    @presenter = Hyrax::Admin::UsersPresenter.new
  end
  # GET /admin/users/new
  def new
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb t(:'hyrax.admin.users.index.title'), new_admin_user_path
    @user = User.new
  end

  def savenew
    @user = User.create(user_params)
    redirect_to admin_users_path
  end

  def destroy
    obj = ActiveFedora::Base::User.find(check_user_request)
    obj.update(deleted_at:Time.now, deleted: obj.deleted ^= true )
    flash[:notice] = "User #{obj.email} successfully #{obj.deleted == false ? I18n.t('admin.users.index.enabled') : I18n.t('admin.users.index.disabled') }"
    redirect_to admin_users_path
  end

  private

  def check_user_request
    if params['id'].blank?
      []
      flash[:notice] = I18n.t('admin.users.index.went_wrong')
      redirect_to :back
    else
      params['id']
    end
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def is_admin?
    redirect_to root_path, notice: I18n.t('admin.users.index.not_authorized') unless current_user.ability.admin?
  end
end
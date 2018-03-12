module Hydra
  module RoleManagement
    module RolesBehavior
      extend ActiveSupport::Concern

      included do
        load_and_authorize_resource
      end

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.manage_roles'), role_management.roles_path
      end

      def show
        @users = @role.users == [] ? ::User.all : ::User.where('email NOT IN (?)', @role.users.pluck(:email))
        redirect_to role_management.edit_role_path(@role) if can? :edit, @role
      end

      def new
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.manage_roles'), role_management.roles_path
      end

      def edit
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.manage_roles'), role_management.edit_role_path(@role)
        @users = @role.users == [] ? ::User.all : ::User.where('email NOT IN (?)', @role.users.pluck(:email))
      end

      def create
        @role = Role.new(role_params)
        if @role.save
          redirect_to role_management.edit_role_path(@role), notice: 'Role was successfully created.'
        else
          render action: "new"
        end
      end

      def update
        @role = Role.find(params[:id])
        if @role.update_attributes(role_params)
          redirect_to role_management.edit_role_path(@role), notice: 'Role was successfully updated.'
        else
          render action: "edit"
        end
      end

      def destroy
        if @role.users == []
          if (@role.destroy)
            redirect_to role_management.roles_path, notice: 'Role was successfully deleted.'
          else
            redirect_to role_management.roles_path
          end
        else
          redirect_to role_management.edit_role_path(@role), notice: 'Role cant be deleted first remove users from current role to continue.'
        end
      end

      private

      def role_params
        if !ActionController.const_defined? :StrongParameters
          params[:role]
        else
          params.require(:role).permit(:name)
        end
      end
    end
  end
end

class RolesController < ApplicationController
  include Hydra::RoleManagement::RolesBehavior
  with_themed_layout 'dashboard'
end


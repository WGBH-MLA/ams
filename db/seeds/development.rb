if ENV['DEV_ADMIN_EMAIL'].present? && ENV['DEV_ADMIN_PASSWORD'].present?
  user = User.find_or_create_by!(email: ENV['DEV_ADMIN_EMAIL']) do |u|
    u.password = ENV['DEV_ADMIN_PASSWORD']
  end

  admin_role = Role.find_or_create_by(name: 'admin')
  aapb_admin_role = Role.find_or_create_by(name: 'aapb-admin')
  user.roles << admin_role unless user.roles.include?(admin_role)
  user.roles << aapb_admin_role unless user.roles.include?(aapb_admin_role)
end

Hyrax::AdminSetCreateService.find_or_create_default_admin_set
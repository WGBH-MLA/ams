[
  { email: 'rob@notch8.com', password: 'testing123' },
  { email: 'support@notch8.com', password: 'testing123' },
  { email: 'admin@example.com', password: 'testing123' },
  { email: 'wgbh_admin@wgbh-mla.org', password: 'pppppp' },
  { email: 'user@notch8.com', password: 'testing123' },
  { email: 'user@example.com', password: 'testing123' }
].each do |set|
  next if User.find_by(email: set[:email])
  user = User.create!(email: set[:email], password: set[:password])
end

admin_role = Role.find_or_create_by(name: 'admin')
aapb_admin_role = Role.find_or_create_by(name: 'aapb-admin')

gbh_administrative_user = User.find_by(email:'wgbh_admin@wgbh-mla.org').roles
notch8_admin = User.find_by(email: 'admin@example.com').roles
notch8_support = User.find_by(email: 'support@notch8.com').roles
rob_admin = User.find_by(email: 'rob@notch8.com').roles

if gbh_administrative_user.any? {|r| r.name == 'admin'} == false
  admin_role.users << User.find_by(email: 'wgbh_admin@wgbh-mla.org')
end

if gbh_administrative_user.any? {|r| r.name == 'aapb-admin'} == false
  aapb_admin_role.users << User.find_by(email: 'wgbh_admin@wgbh-mla.org')
end

if notch8_admin.any? {|r| r.name == 'admin'} == false
  admin_role.users << User.find_by(email: 'admin@example.com')
end

if notch8_admin.any? {|r| r.name == 'aapb-admin'} == false
  aapb_admin_role.users << User.find_by(email: 'admin@example.com')
end

if notch8_support.any? {|r| r.name == 'admin'} == false
  admin_role.users << User.find_by(email: 'support@notch8.com')
end

if notch8_support.any? {|r| r.name == 'aapb-admin'} == false
  aapb_admin_role.users << User.find_by(email: 'support@notch8.com')
end

if rob_admin.any? {|r| r.name == 'admin'} == false
  admin_role.users << User.find_by(email: 'rob@notch8.com')
end

if rob_admin.any? {|r| r.name == 'aapb-admin'} == false
  aapb_admin_role.users << User.find_by(email: 'rob@notch8.com')
end

# TODO `Hyrax::AdminSetCreateService.find_or_create_default_admin_set` does not work
# it just spins forever because it tries to load all associated models
if App.rails_5_1?
  admin_set = AdminSet.find(Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s)
else
  begin
    admin_set = AdminSet.find(Hyrax::AdminSetCreateService::DEFAULT_ID)
  rescue ActiveFedora::ObjectNotFoundError
    Hyrax::AdminSetCreateService.create_default_admin_set
    admin_set = AdminSet.find(Hyrax::AdminSetCreateService::DEFAULT_ID)
  end
end

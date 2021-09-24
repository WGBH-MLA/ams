[
  { email: 'rob@notch8.com', password: 'testing123' },
  { email: 'support@notch8.com', password: 'testing123' },
  { email: 'admin@example.com', password: 'testing123' },
  { email: 'user@notch8.com', password: 'testing123' },
  { email: 'user@example.com', password: 'testing123' }
].each do |set|
  next if User.find_by(email: set[:email])
  user = User.create!(email: set[:email], password: set[:password])
end
admin = Role.find_or_create_by(name: 'admin')
admin.users << User.find_by(email: 'rob@notch8.com')
admin.users << User.find_by(email: 'support@notch8.com')
admin.users << User.find_by(email: 'admin@example.com')
admin.save
aapb_admin = Role.find_or_create_by(name:'aapb-admin')
aapb_admin.users << User.find_by(email: 'rob@notch8.com')
aapb_admin.users << User.find_by(email: 'support@notch8.com')
aapb_admin.users << User.find_by(email: 'admin@example.com')
aapb_admin.save

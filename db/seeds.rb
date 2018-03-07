# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Creates default admin user

puts "======================"
puts "Creating default admin user: wgbh_admin@wgbh-mla.org"
User.create(email: "wgbh_admin@wgbh-mla.org", password: "pa$$w0rd")
puts "======================"

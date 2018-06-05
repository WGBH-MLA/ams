# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Creates default admin user


Rails.logger.info 'Creating default admin user.'
User.create(email: "wgbh_admin@wgbh-mla.org", password: "pa$$w0rd")

Rails.logger.info 'Creating admin role.'
Role.create(name:'admin',users: [User.last])


Rails.logger.info "Creating Series collection type."
machine_id = 'series'
series_collection_type = Hyrax::CollectionType.find_by(machine_id: machine_id)
unless series_collection_type.present?
  options = {
    description: 'Series',
    nestable: true,
    brandable: false,
    discoverable: true,
    sharable: false,
    share_applies_to_new_works: false,
    allow_multiple_membership: true,
    require_membership: false,
    assigns_workflow: false,
    assigns_visibility: false,
    badge_color: '#FF7F4F',
    participants: [{ agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE, agent_id: 'admin', access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS },
                   { agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE, agent_id: ::Ability.registered_group_name, access: Hyrax::CollectionTypeParticipant::CREATE_ACCESS }]
  }
  Hyrax::CollectionTypes::CreateService.create_collection_type(machine_id: machine_id, title: 'Series', options: options)
end

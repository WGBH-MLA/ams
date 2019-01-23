FactoryBot.define do
  factory :instantiation_admin_data, class: 'InstantiationAdminData' do
    aapb_preservation_lto {"Test LTO"}
    aapb_preservation_disk {"Test Disk"}
  end
end

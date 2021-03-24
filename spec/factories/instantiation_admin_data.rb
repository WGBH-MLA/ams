FactoryBot.define do
  factory :instantiation_admin_data, class: 'InstantiationAdminData' do
    aapb_preservation_lto {"Test LTO"}
    aapb_preservation_disk {"Test Disk"}
    md5 { Digest::MD5.hexdigest(rand(999999).to_s) }
  end
end

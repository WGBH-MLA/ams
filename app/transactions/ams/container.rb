require 'dry/container'

module Ams
  class Container
    extend Dry::Container::Mixin

    namespace 'change_set' do |ops|
      ops.register "handle_contributors" do
        Ams::Steps::HandleContributors.new
      end

      ops.register "create_aapb_admin_data" do
        Ams::Steps::CreateAapbAdminData.new
      end

      ops.register 'create_work' do
        Ams::WorkCreate.new
      end

      ops.register 'update_work' do
        Ams::WorkUpdate.new
      end
    end
  end
end

module Ams
  class Container
    extend Dry::Container::Mixin
    require 'hyrax/transactions/steps/create_aapb_admin_data'

    namespace 'change_set' do |ops|
      ops.register "create_aapb_admin_data" do
        Hyrax::Transactions::Steps::CreateAapbAdminData.new
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

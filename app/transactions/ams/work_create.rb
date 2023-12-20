# Extend Hyrax::Transactions::WorkCreate to create aapb admin data

module Ams
  class WorkCreate < Hyrax::Transactions::Transaction
    DEFAULT_STEPS = ['change_set.set_default_admin_set',
      'change_set.ensure_admin_set',
      'change_set.set_user_as_depositor',
      'change_set.create_aapb_admin_data',
      'change_set.add_data_from_pbcore',
      'change_set.handle_contributors',
      'change_set.apply',
      'work_resource.apply_permission_template',
      'work_resource.save_acl',
      'work_resource.add_file_sets',
      'work_resource.change_depositor',
      'work_resource.add_to_parent'].freeze

    ##
    # @see Hyrax::Transactions::Transaction
    def initialize(container: Container, steps: DEFAULT_STEPS)
      super(steps: steps)
    end
  end
end

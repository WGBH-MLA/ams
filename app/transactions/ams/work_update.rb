# frozen_string_literal: true

module Ams
  class WorkUpdate < Hyrax::Transactions::Transaction
    DEFAULT_STEPS = ['change_set.create_aapb_admin_data',
                      'change_set.add_data_from_pbcore',
                      'change_set.handle_contributors',
                      'change_set.apply',
                      'work_resource.save_acl',
                      'work_resource.add_file_sets',
                      'work_resource.update_work_members'].freeze

    ##
    # @see Hyrax::Transactions::Transaction
    def initialize(container: ::Ams::Container, steps: DEFAULT_STEPS)
      super(steps: steps)
    end
  end
end

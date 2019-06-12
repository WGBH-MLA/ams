module DepositHelpers
    # Creates the apparatus needed for depositing/ingesting things.
    # This doesn't memoize anything, but it can be used within a :let if you
    # want to memoize.
    # @return [Array<User,AdminSet>] A 2-element array consisting of the
    #  factory-generated User and AdminSet instances.
    def create_user_and_admin_set_for_deposit
      admin_set = FactoryBot.create(:admin_set)
      user_role = "TestRole#{rand.to_s[2..5]}"
      user = FactoryBot.create(:user, role_names: [user_role])
      permission_template = FactoryBot.create(:permission_template, source_id: admin_set.id)
      permission_template_access = FactoryBot.create(
        :permission_template_access,
        permission_template: permission_template,
        agent_id: user_role,
        agent_type: 'group',
        access: 'deposit'
      )
      # Return the user and the admin set.
      [user, admin_set]
    end
end

RSpec.configure { |c| c.include DepositHelpers }

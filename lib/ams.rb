require 'benchmark'

module AMS
  class << self
    # Accessor for logger used by AMS
    def logger
      @logger ||= Logger.new(STDOUT).tap do |logger|
        # Simplify the formatter to just be the message with newlines.
        logger.formatter = -> (_severity, _datetime, _progname, msg) { "\n#{msg}\n" }
        logger.level = ENV.fetch('AMS_LOG_LEVEL', Logger::WARN).to_i
      end
    end

    def seeds; Seed; end

    module Seed
      class << self
        def all
          {
            admin_user: admin_user,
            admin_role: admin_role,
            aapb_admin_role: aapb_admin_role,
            admin_set: admin_set
          }
        end

        def admin_user
          user = User.find_by email: "wgbh_admin@wgbh-mla.org"
          return user if user
          User.create!(email: "wgbh_admin@wgbh-mla.org", password: "pppppp")
        end

        def admin_role
          role = Role.find_by name: 'admin'
          return role if role
          Role.create!(name:'admin', users: [admin_user])
        end

        def aapb_admin_role
          role = Role.find_by name: 'aapb-admin'
          return role if role
          Role.create!(name: 'aapb-admin', users: [admin_user])
        end

        def admin_set
          Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s
        end
      end
    end
  end
end

module AMS
  module CascadeDestroyMembers
    extend ActiveSupport::Concern

    included do
      after_destroy do
        members.each do |member|
          member.destroy!
        end
      end
    end
  end
end

module AMS
  module AllNestedMembersMethods

    def all_nested_members
      all_members = []
      members.each do |mem|
        all_members << get_members(mem)
      end
      all_members.flatten
    end

    private

    # Recursively get all members off of members
    def get_members(object)
      objects = [ object ]

      object.members.each do |member|
        objects << member

        member.members.each do |mem|
          get_members(mem)
        end
      end
      objects
    end
  end
end
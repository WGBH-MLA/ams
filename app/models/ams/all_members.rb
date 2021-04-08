module AMS
  module AllMembers
    def self.included(base)
      base.extend ClassMethods
    end

    # Memoized access for recursively fetching object hierarchy via #members
    # association.
    def all_members(only: [], except: [])
      only, except = Array(only).map(&:to_s), Array(except).map(&:to_s)
      @all_members ||= self.class.get_members(self) - [ self ]
      filtered = @all_members.select { |m| only.empty? || only.include?(m.class.to_s) }
      filtered.reject { |m| except.include?(m.class.to_s) }
    end

    module ClassMethods
      # Recursively get members
      def get_members(object)
        [ object ] + object.members.map { |member| get_members(member) }.flatten
      end
    end
  end
end

module AMS
  module NonExactDateService
    def self.regex
      regex =  /\A[1-9][0-9]{3}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31))\z|\A[1-9][0-9]{3}-(?:0[1-9]|1[0-2])\z|\A[1-9][0-9]{3}\z/;
      class << regex
        def to_s
          super.gsub('\\A' , '^').
              gsub('\\Z' , '$').
              gsub('\\z' , '$').
              gsub(/^\// , '').
              gsub(/\/[a-z]*$/ , '').
              gsub(/\(\?#.+\)/ , '').
              gsub(/\(\?-\w+:/ , '(').
              gsub(/\s/ , '')
        end
      end
      return regex
    end

    def self.valid?(value)
       if (value =~ self.regex).nil?
          return false
       else
          return true
       end
    end

    def self.invalid?(val)
      return !self.valid?(val)
    end
  end
end
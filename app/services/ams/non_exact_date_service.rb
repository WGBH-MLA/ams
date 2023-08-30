module AMS
  module NonExactDateService
    def self.regex
      /\A[1-9][0-9]{3}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31))\z|\A[1-9][0-9]{3}-(?:0[1-9]|1[0-2])\z|\A[1-9][0-9]{3}\z/;
    end

    def self.regex_string
      "(^[1-9][0-9]{3}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31))$|^[1-9][0-9]{3}-(?:0[1-9]|1[0-2])$|^[1-9][0-9]{3}$)"
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

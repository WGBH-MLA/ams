module AMS
  module TimeCodeService
    class << self
      def regex
        Regexp.new regex_for_html
      end

      def regex_for_html
        '\A(\d+:\d\d:\d\d|\d\d?:\d\d)(\.\d+)?\z'
      end
    end
  end
end

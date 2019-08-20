module AAPB
  module BatchIngest
    class Error < StandardError; end

    class RecordExists < Error
      def initialize(id)
        super "A record with id '#{id}' already exists"
      end
    end
  end
end

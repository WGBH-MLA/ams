module Devise
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers
      def current_user
        User.first
      end
    end
  end
end

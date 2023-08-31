# frozen_string_literal: true

# OVERRIDE Hyrax 4.0.0 AdminSetCreateService to return first admin set (default)
# until timeout issue is resolved
module Hyrax
  module AdminSetCreateServiceDecorator
    private

    def find_default_admin_set
        AdminSet.first
    end
  end
end

Hyrax::AdminSetCreateService.singleton_class.send(:prepend, Hyrax::AdminSetCreateServiceDecorator)
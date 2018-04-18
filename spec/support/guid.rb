module GuidHelpers
  def guid_regex
    /cpb-aacip_600-[0-9b-z][0-9b-z][0-9][0-9b-z][0-9b-z][0-9][0-9b-z][0-9b-z][0-9][0-9b-z]/i
  end
end

# Add the GuidHelpers methods to RSpec tests.
RSpec.configure do |config|
  config.include GuidHelpers
end

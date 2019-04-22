module GuidHelpers
  def guid_regex
    # Regex for verifying valid ID format of...
    # 1. "cpb-aacip-" prefix (required)
    # 2. 1-3 digit number, followed by dash (optional)
    # 3. 6+ digit number (required)
    /cpb-aacip-(\d{1,3}\-)?[0-9a-z]{6,}/i
  end
end

# Add the GuidHelpers methods to RSpec tests.
RSpec.configure do |config|
  config.include GuidHelpers
end

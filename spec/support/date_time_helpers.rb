module DateTimeHelpers
  def rand_date_time(after: DateTime.now - 1.year, before: DateTime.now)
    after = DateTime.parse(after.to_s)
    before = DateTime.parse(before.to_s)
    offset = rand(before.to_i - after.to_i)
    after + offset.seconds
  end
end

# Add the DateTimeHelper methods to RSpec tests.
RSpec.configure do |config|
  config.include DateTimeHelpers
end

# Hardcoded seeds removed - load environment-specific seeds instead

puts "Loading seeds for #{Rails.env} environment while RAILS_ENV is set to #{ENV['RAILS_ENV']}"
env_seed = Rails.root.join("db", "seeds", "#{Rails.env}.rb")
load(env_seed) if env_seed.exist?
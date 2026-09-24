# Hardcoded seeds removed - load environment-specific seeds instead
puts "Loading seeds for environment: #{Rails.env}")
env_seed = Rails.root.join("db", "seeds", "#{Rails.env}.rb")
load(env_seed) if env_seed.exist?
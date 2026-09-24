# Hardcoded seeds removed - load environment-specific seeds instead
Rails.logger.info("Loading seeds for environment: #{Rails.env}")
env_seed = Rails.root.join("db", "seeds", "#{Rails.env}.rb")
load(env_seed) if env_seed.exist?
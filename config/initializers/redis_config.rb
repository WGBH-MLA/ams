require 'redis'
config = YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Hyrax.config.redis_connection = begin
                                  Redis.new(config.merge(thread_safe: true))
                                rescue
                                  nil
                                end

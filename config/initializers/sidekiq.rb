config = YAML.load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access

url = Rails.env == 'production' ? "redis://:#{config[:password]}@#{config[:host]}:#{config[:port]}/" : "redis://#{config[:host]}:#{config[:port]}/"

redis_conn = if App.rails_5_1?
  { url: url, network_timeout: config[:network_timeout] }
else
  { url: url }
end

Sidekiq.configure_server do |s|
  s.redis = redis_conn
end

Sidekiq.configure_client do |s|
  s.redis = redis_conn
end

Sidekiq.logger.level = Logger::DEBUG
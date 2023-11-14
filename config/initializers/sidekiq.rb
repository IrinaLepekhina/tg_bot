# /config/initializers/sidekiq.rb

redis_host     = ENV.fetch('REDIS_HOST', 'localhost')
redis_port     = ENV.fetch('REDIS_PORT', '6379')
redis_database = ENV.fetch('REDIS_DATABASE', '0')
redis_url      = "redis://#{redis_host}:#{redis_port}/#{redis_database}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

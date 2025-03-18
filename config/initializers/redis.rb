require 'yaml'

redis_config = {
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
  timeout: ENV.fetch('REDIS_TIMEOUT', 1).to_i
}

$redis = Redis.new(redis_config)

# Configure Redis for Sidekiq
Sidekiq.configure_server do |config|
  config.redis = { 
    url: redis_config[:url],
    pool_timeout: ENV.fetch('REDIS_POOL_TIMEOUT', 5).to_i
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_config[:url],
    pool_timeout: ENV.fetch('REDIS_POOL_TIMEOUT', 5).to_i
  }
end

# Configure Action Cable
Rails.application.configure do
  config.action_cable.url = ENV.fetch('ACTION_CABLE_URL', 'ws://localhost:3000/cable')
  config.action_cable.allowed_request_origins = ENV.fetch('CORS_ALLOWED_ORIGINS', 'http://localhost:3000').split(',').map(&:strip)
  config.action_cable.cable = { 
    adapter: 'redis',
    url: ENV.fetch('ACTION_CABLE_REDIS_URL', redis_config[:url])
  }
end 
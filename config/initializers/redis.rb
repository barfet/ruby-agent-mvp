require 'yaml'

redis_config = YAML.load_file(Rails.root.join('config', 'redis.yml'))[Rails.env].symbolize_keys

$redis = Redis.new(redis_config)

# Configure Redis for Sidekiq
Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Configure Redis for Action Cable
Rails.application.configure do
  config.action_cable.url = ENV.fetch('ACTION_CABLE_URL', 'ws://localhost:3000/cable')
  config.action_cable.allowed_request_origins = ENV.fetch('CORS_ALLOWED_ORIGINS', '*').split(',').map(&:strip)
  config.action_cable.cable_url = ENV.fetch('ACTION_CABLE_REDIS_URL', redis_config[:url])
end 
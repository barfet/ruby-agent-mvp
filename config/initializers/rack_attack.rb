class Rack::Attack
  ### Configure Cache ###
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'))

  ### Throttle Spammy Clients ###
  throttle('req/ip', limit: ENV.fetch('RATE_LIMIT_MAX_REQUESTS', 300).to_i, period: ENV.fetch('RATE_LIMIT_PERIOD', 5.minutes).to_i) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###
  throttle('logins/ip', limit: ENV.fetch('LOGIN_RATE_LIMIT_MAX', 5).to_i, period: ENV.fetch('LOGIN_RATE_LIMIT_PERIOD', 20.seconds).to_i) do |req|
    if req.path == '/login' && req.post?
      req.ip
    end
  end

  ### Custom Throttle Response ###
  self.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']

    headers = {
      'Content-Type' => 'application/json',
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
    }

    [429, headers, [{ error: "Too many requests. Please try again later." }.to_json]]
  end
end 
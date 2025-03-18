OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY')
  config.organization_id = ENV['OPENAI_ORGANIZATION_ID'] if ENV['OPENAI_ORGANIZATION_ID'].present?
  config.request_timeout = ENV.fetch('OPENAI_REQUEST_TIMEOUT', 120).to_i
end 
if ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', 0.5).to_f

    config.environment = Rails.env
    config.enabled_environments = %w[production staging]

    config.before_send = lambda do |event, hint|
      # Scrub sensitive data
      if event.request
        event.request.data = event.request.data.dup
        %w[password password_confirmation current_password].each do |field|
          event.request.data.delete(field) if event.request.data.key?(field)
        end
      end
      event
    end
  end
end 
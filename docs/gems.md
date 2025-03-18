# Gem Dependencies Documentation

## Core Dependencies

- `ruby-openai` (~> 6.3) - Official Ruby client for the OpenAI API, used for interacting with GPT models
- `rack-attack` (~> 6.7) - Rack middleware for blocking & throttling abusive requests
- `dotenv-rails` (~> 3.0) - Loads environment variables from `.env` files
- `sidekiq` (~> 7.2) - Background job processing using Redis
- `faraday` (~> 2.9) - HTTP client library for making API requests with persistent connections
- `rswag` (~> 2.13) - Swagger/OpenAPI documentation generator for Rails APIs
- `sentry-ruby` & `sentry-rails` (~> 5.16) - Error tracking and performance monitoring
- `rack-cors` (~> 2.0) - Handles Cross-Origin Resource Sharing (CORS)
- `secure_headers` (~> 6.5) - Security headers for Rails applications
- `bcrypt` (~> 3.1.7) - Password hashing algorithm for secure authentication

## Development & Testing Dependencies

### Development
- `better_errors` (~> 2.10) - Better error page for Rails applications
- `binding_of_caller` (~> 1.0) - Retrieve the binding of a method's caller
- `bullet` (~> 7.1) - Helps detect N+1 queries and unused eager loading
- `rack-mini-profiler` (~> 3.3) - Performance profiling tool
- `pry-rails` (~> 0.3.9) - Enhanced Rails console
- `foreman` (~> 0.88.1) - Process manager for Procfile-based applications

### Testing
- `rspec-rails` (~> 6.1) - Testing framework for Rails
- `factory_bot_rails` (~> 6.4) - Fixtures replacement with a more flexible approach
- `faker` (~> 3.2) - Library for generating fake data
- `simplecov` (~> 0.22.0) - Code coverage analysis tool
- `webmock` (~> 3.19) - Library for stubbing HTTP requests
- `vcr` (~> 6.2) - Record and replay HTTP interactions

## Rails Default Dependencies

- `rails` (~> 8.0.2) - Web application framework
- `pg` (~> 1.1) - PostgreSQL database adapter
- `puma` (>= 5.0) - Web server
- `importmap-rails` - JavaScript module bundling
- `turbo-rails` - Hotwire's SPA-like page accelerator
- `stimulus-rails` - Hotwire's JavaScript framework
- `tailwindcss-rails` - CSS framework
- `jbuilder` - JSON API builder
- `bootsnap` - Boot time optimizer
- `image_processing` (~> 1.2) - Image processing for Active Storage
- `debug` - Debugging tools
- `brakeman` - Security vulnerability scanner
- `rubocop-rails-omakase` - Ruby code style checker
- `capybara` - System testing framework
- `selenium-webdriver` - Browser automation for testing 
# Minimal Puma configuration for Docker
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Bind to all interfaces inside Docker
bind "tcp://0.0.0.0:3000"

# Set environment
rails_env = ENV.fetch("RAILS_ENV") { "development" }
environment rails_env

# Set up workers
if rails_env == "development"
  worker_timeout 3600
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  preload_app!
end

# Allow puma to be restarted
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# On worker boot, reconnect to the database
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

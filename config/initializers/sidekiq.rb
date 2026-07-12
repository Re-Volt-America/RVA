# Sidekiq configuration.
#
# Sidekiq is used to run heavy work (such as parsing uploaded Session logs) in
# the background, so that admins uploading a Session are not left waiting on a
# loading page while the file is processed.
#
# We reuse the same Redis server already used for the Rails cache store, but on
# a separate logical database (db 1) so background jobs and cached fragments
# never step on each other.

require 'sidekiq'

redis_url = ENV.fetch('REDIS_URL') do
  host = ENV.fetch('REDIS_HOST', 'localhost')
  port = ENV.fetch('REDIS_PORT', 6379)
  "redis://#{host}:#{port}/1"
end

Sidekiq.configure_server do |config|
  config.redis = { :url => redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => redis_url }
end

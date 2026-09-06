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
require 'cgi'

redis_url = ENV.fetch('REDIS_URL') do
  host     = ENV.fetch('REDIS_HOST', 'localhost')
  port     = ENV.fetch('REDIS_PORT', 6379)
  password = ENV['REDIS_PASSWORD']

  # Prefix ":password@" only when a password is configured, so a password-less
  # development Redis keeps working unchanged while production authenticates.
  userinfo = password.to_s.empty? ? '' : ":#{CGI.escape(password)}@"

  "redis://#{userinfo}#{host}:#{port}/1"
end

Sidekiq.configure_server do |config|
  config.redis = { :url => redis_url }

  # Periodic safety net for stranded imports.
  #
  # A SessionImport record lives in MongoDB (durable) while the job that
  # processes it lives only in Redis. If Redis ever loses that job (via a restart,
  # a redeploy that recreates the container, or a flush) the import is stranded
  # at "pending" forever and Sidekiq shows nothing queued. This cron sweeps
  # every 5 minutes and marks any clearly-stalled import as failed (with a
  # reason) so it stops sitting in limbo.
  config.on(:startup) do
    if defined?(Sidekiq::Cron::Job)
      job = Sidekiq::Cron::Job.new(
        :name       => 'Session import sweeper',
        :cron       => '*/5 * * * *',
        :class      => 'SessionImportSweeperJob',
        :queue      => 'default',
        :active_job => true
      )

      if job.save
        Sidekiq.logger.info('[cron] registered "Session import sweeper" (*/5 * * * *)')
      else
        Sidekiq.logger.error("[cron] could NOT register sweeper: #{job.errors.join('; ')}")
      end
    else
      Sidekiq.logger.error('[cron] sidekiq-cron not loaded; sweeper NOT scheduled')
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => redis_url }
end

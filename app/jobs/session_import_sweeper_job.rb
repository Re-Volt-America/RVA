# Safety net for Session imports whose background job was lost.
#
# A SessionImport is created in MongoDB (durable) and its SessionImportJob is
# enqueued in Redis (ephemeral). If Redis ever loses that job, for example a
# restart, a redeploy that recreates the container, or a flush, the Mongo
# record is stranded at "pending" forever while Sidekiq shows nothing queued.
# Nothing else touches it, so the upload silently never finishes.
#
# This sweeper runs every few minutes (scheduled via sidekiq-cron in
# config/initializers/sidekiq.rb) and marks anything that has clearly stalled
# as FAILED, with an admin-facing reason, so the import stops sitting in limbo
# and the uploader is prompted to try again rather than waiting indefinitely.
# We deliberately do NOT re-enqueue: a lost job's file/params may no longer be
# trustworthy, so a stranded import is surfaced as a failure for a human to
# re-run, not retried automatically.
class SessionImportSweeperJob < ApplicationJob
  queue_as :default

  # A pending import whose job has not started within this window is presumed
  # lost. Comfortably longer than a normal parse so we never race the happy path.
  PENDING_GRACE = 5.minutes

  # A processing import older than this is presumed to be a dead worker (a
  # normal parse takes seconds), so it is safe to fail without racing a
  # still-running job.
  PROCESSING_GRACE = 1.hour

  PENDING_MESSAGE = 'Import never started: its background job was lost before ' \
                    'processing (Redis restart, redeploy, or flush). Please ' \
                    're-upload the session log to try again.'.freeze

  PROCESSING_MESSAGE = 'Import stalled: the worker processing this session ' \
                       'stopped before finishing (Redis/Sidekiq crash). Please ' \
                       're-upload the session log to try again.'.freeze

  def perform
    fail_lost_pending
    fail_dead_processing
  end

  private

  # Imports that were enqueued but whose job never picked them up.
  def fail_lost_pending
    SessionImport
      .where(:status => SessionImport::PENDING, :created_at.lt => PENDING_GRACE.ago)
      .each { |import| mark_failed(import, PENDING_MESSAGE) }
  end

  # Imports whose worker died mid-parse (Redis/Sidekiq crash) with no retry
  # coming.
  def fail_dead_processing
    SessionImport
      .where(:status => SessionImport::PROCESSING, :started_at.lt => PROCESSING_GRACE.ago)
      .each { |import| mark_failed(import, PROCESSING_MESSAGE) }
  end

  def mark_failed(import, message)
    finished = Time.current

    import.update(
      :status          => SessionImport::FAILED,
      :error_message   => message,
      :error_backtrace => "SessionImportSweeperJob: #{message}",
      :finished_at     => finished,
      :duration_ms     => import.started_at ? ((finished - import.started_at) * 1000).round : nil
    )

    Rails.logger.warn("[SessionImportSweeper] failing stranded SessionImport #{import.id}: #{message}")
    Sentry.capture_message("Stranded SessionImport #{import.id} marked failed: #{message}") if defined?(Sentry)
  end
end

# Parses an uploaded Session log in the background.
#
# The heavy lifting (CSV parsing, results calculation and stats/points
# application) previously happened inline during the web request, forcing the
# uploading admin to wait on a loading page. It now runs here, asynchronously,
# while a SessionImport record tracks progress for the Administration Panel.
class SessionImportJob < ApplicationJob
  queue_as :default

  def perform(session_import_id)
    require 'csv_import_sessions_service'

    import = SessionImport.where(:id => session_import_id).first
    return if import.nil?

    started = Time.current
    import.update(:status => SessionImport::PROCESSING, :started_at => started)

    session = nil

    # Shrine downloads the stored CSV to a local Tempfile the parser can read.
    import.session_log.download do |file|
      session = CsvImportSessionsService.new(
        file,
        import.ranking_id,
        import.category,
        nil,
        import.teams
      ).call

      raise 'The uploaded file could not be parsed as a Re-Volt session log.' if session.nil?

      # Re-attach the original stored upload so the Session keeps proper file
      # metadata (name, size, mime type) instead of the temporary download's.
      session.session_log = import.session_log

      unless session.save
        raise "Session could not be saved: #{session.errors.full_messages.join(', ')}"
      end
    end

    finished = Time.current
    import.update(
      :status => SessionImport::COMPLETED,
      :session_id => session.id,
      :session_number => session.number,
      :finished_at => finished,
      :duration_ms => ((finished - started) * 1000).round
    )

    invalidate_session_caches
  rescue StandardError => e
    finished = Time.current
    started_at = import&.started_at
    import&.update(
      :status => SessionImport::FAILED,
      :error_message => e.message,
      :finished_at => finished,
      :duration_ms => started_at ? ((finished - started_at) * 1000).round : nil
    )

    Sentry.capture_exception(e) if defined?(Sentry)

    # Parse failures are deterministic (bad file, missing ranking, ...), so we
    # deliberately do not re-raise: retrying would only fail again. The failure
    # is recorded on the SessionImport for the admin to inspect.
  end

  private

  def invalidate_session_caches
    Rails.cache.delete('recent_sessions')
    Rails.cache.delete('current_sessions')
    Rails.cache.delete('current_ranking')
  end
end

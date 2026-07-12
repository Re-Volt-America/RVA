module AdminHelper
  # Renders a themed status badge for a SessionImport status. Colours are
  # defined in admin.scss (.status-badge.status-*).
  def import_status_badge(status)
    content_tag(:span, status.to_s.capitalize, :class => "status-badge status-#{status}")
  end

  # Links a SessionImport's uploader to their profile ("—" when unknown).
  def import_uploader_link(import)
    user = import.uploaded_by
    return content_tag(:span, "—") if user.nil?

    link_to(user.username, user_path(user))
  end

  # Links a SessionImport to the session it produced, shown as the session's
  # hash id ("—" when there is no session yet).
  def import_session_link(import)
    session = import.result_session
    return content_tag(:span, "—") if session.nil?

    link_to(session.id.to_s, session_path(session))
  end

  # Human readable duration for a SessionImport ("—" when unknown).
  def import_duration(import)
    seconds = import.duration_seconds
    return '—' if seconds.nil?

    if seconds < 1
      "#{(seconds * 1000).round} ms"
    elsif seconds < 60
      format('%.1f s', seconds)
    else
      minutes = (seconds / 60).floor
      remainder = (seconds % 60).round
      "#{minutes}m #{remainder}s"
    end
  end
end

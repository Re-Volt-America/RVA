# frozen_string_literal: true

module NotificationsHelper
  # Font Awesome icon class for a notification (trophy notifications reuse the
  # earned trophy's icon).
  def notification_icon(notification)
    case notification.kind
    when 'trophy'
      notification.trophy&.icon || 'fa-bell'
    else
      'fa-bell'
    end
  end

  # Translated one-line message, rendered in the *viewer's* language.
  def notification_message(notification)
    case notification.kind
    when 'trophy'
      name = notification.trophy&.name || t('users.trophies.unknown')
      t('notifications.trophy-earned', :name => name)
    else
      ''
    end
  end

  # Where clicking the notification takes the user.
  def notification_link(notification)
    case notification.kind
    when 'trophy'
      user_signed_in? ? user_path(current_user.username, :anchor => 'trophies') : '#'
    else
      '#'
    end
  end
end

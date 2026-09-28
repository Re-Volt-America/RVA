# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # Full notification history. Visiting the page marks everything as read.
  def index
    @notifications = current_user.notifications
                                 .recent
                                 .page(params[:page])
                                 .per(20)

    # The in-memory @notifications keep their (possibly unread) state for this
    # render so the page can highlight what was new; the DB is updated so the
    # bell badge clears on the next request.
    current_user.notifications.unread.update_all(:read => true)
  end

  # Explicit "mark all as read" action (e.g. from the bell dropdown).
  def mark_all_read
    current_user.notifications.unread.update_all(:read => true)

    respond_to do |format|
      format.html { redirect_back :fallback_location => notifications_path }
    end
  end
end

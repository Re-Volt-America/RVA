# Uploader-facing view of a background Session import.
#
# After an organizer/admin uploads a Session log (SessionsController#import),
# they are redirected here to watch a progress bar instead of being dumped back
# on the home page. The `status` action is polled as JSON by the progress
# screen; when the import completes the screen forwards the user straight to the
# resulting Session's results page.
#
# This is intentionally separate from Admin::SessionImportsController (the
# admin-only monitoring panel): it is reachable by any organizer, but only for
# their own imports (admins may view any).
class SessionImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_organizer
  before_action :set_import

  # GET /session_imports/:id — the progress screen (full HTML page).
  def show; end

  # GET /session_imports/:id/status — JSON snapshot polled by the progress
  # screen. Kept tiny: status plus, when finished, where to go next / why it
  # failed.
  def status
    render :json => import_status_payload, :layout => false
  end

  private

  def set_import
    @import = SessionImport.where(:id => params[:id]).first

    if @import.nil?
      redirect_to(root_path, :notice => t('rankings.sessions.controller.import.not_found')) and return
    end

    # Organizers may only follow their own uploads; admins may follow any.
    return if user_is_admin? || @import.uploaded_by == current_user

    redirect_to(root_path, :notice => t('alerts.no-permission'))
  end

  def import_status_payload
    {
      :status => @import.status,
      :completed => @import.completed?,
      :failed => @import.failed?,
      :session_url => completed_session_url,
      :error_message => (@import.error_message if @import.failed?)
    }
  end

  # Where to send the user once the import finishes successfully. Falls back to
  # the home page if the produced Session no longer exists.
  def completed_session_url
    return nil unless @import.completed?

    session = @import.result_session
    session ? session_path(session) : root_path
  end
end

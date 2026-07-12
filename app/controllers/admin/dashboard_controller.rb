module Admin
  # Landing page of the Administration Panel: a hub linking to each admin
  # section, with a few at-a-glance figures.
  class DashboardController < BaseController
    def index
      @users_count = User.count
      @sessions_count = Session.count

      @imports_in_progress = SessionImport.in_progress.to_a
      @recent_imports = SessionImport.finished.limit(5).to_a
      @completed_count = SessionImport.where(:status => SessionImport::COMPLETED).count
      @failed_count = SessionImport.where(:status => SessionImport::FAILED).count
    end
  end
end

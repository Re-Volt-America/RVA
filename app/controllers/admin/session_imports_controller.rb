module Admin
  # Session parsing monitor: shows Session logs currently being parsed in the
  # background as well as recently finished imports (with timing and outcome).
  class SessionImportsController < BaseController
    def index
      @in_progress = SessionImport.in_progress.to_a
      @imports = Kaminari.paginate_array(SessionImport.finished.to_a).page(params[:page]).per(20)
    end

    def show
      @import = SessionImport.where(:id => params[:id]).first

      redirect_to(admin_session_imports_path, :notice => t('.not_found')) and return if @import.nil?
    end
  end
end

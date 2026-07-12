class SessionsController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :authenticate_organizer, :except => [:index, :show]
  before_action :set_session, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /sessions or /sessions.json
  def index
    @sessions = Session.all
    @sessions = Kaminari.paginate_array(@sessions).page(params[:page]).per(8)

    respond_with @sessions do |format|
      format.json { render :layout => false }
    end
  end

  # GET /sessions/1 or /sessions/1.json
  def show
    require 'session_results_table'

    @results_table = SessionResultsTable.from_serialized(@session.results_data, :session => @session)

    if @results_table.rows.empty?
      require 'rva_calculate_results_service'

      rva_results = RvaCalculateResultsService.new(@session).call
      @results_table = SessionResultsTable.from_legacy_array(rva_results, @session)
      @session.set(:results_data => @results_table.as_serialized)
    end

    # Car usage analysis
    @car_usage = @results_table.rows.each_with_object(Hash.new(0)) do |row, hash|
      cars = row.cars.select { |car| car.is_a?(Car) }
      cars.each do |car|
        next unless car.respond_to?(:name)
        hash[car.name] += 1
      end
    end.sort_by { |_, count| -count }.to_h  # Sort by frequency in descending order

    respond_with @session do |format|
      format.json { render :layout => false }
    end
  end

  # GET /sessions/new
  def new
    @session = Session.new
  end

  # GET /sessions/1/edit
  def edit; end

  # POST /sessions or /sessions.json
  def create
    @session = Session.new(session_params)

    respond_to do |format|
      if @session.save
        format.html { redirect_to session_url(@session), :notice => t('rankings.sessions.controller.create') }
        format.json { render :show, :status => :created, :location => @session, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @session.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /sessions/1 or /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to session_url(@session), :notice => t('rankings.sessions.controller.update') }
        format.json { render :show, :status => :ok, :location => @session, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @session.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # DELETE /sessions/1 or /sessions/1.json
  def destroy
    require 'stats_service'
    require 'team_points_service'

    if @session.teams?
      TeamPointsService.new(@session).remove_team_points
    else
      StatsService.new(@session).remove_stats
    end

    respond_to do |format|
      if @session.destroy!
        format.html { redirect_to sessions_url, :notice => t('rankings.sessions.controller.delete') }
        format.json { head :no_content }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @session.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  def rankings
    @target = params[:target]
    @rankings = Ranking.where(:season_id => params[:season]).collect { |r| [r.number, r.id] }

    respond_to do |format|
      format.turbo_stream { render :layout => false }
    end
  end

  # NOTE: Game physics and other info present in the session log headers is only captured for the first race.
  #
  # The uploaded log is persisted as a SessionImport and parsed in the
  # background by SessionImportJob, so the admin is not left waiting on the
  # request. Progress can be followed in the Administration Panel.
  def import
    file = params[:session_log]

    if file.nil?
      respond_to do |format|
        format.html { redirect_to new_session_path, :notice => t('misc.controller.import.select') }
        format.json { render :json => t('misc.controller.import.select'), :status => :bad_request, :layout => false }
      end and return
    end

    unless SYS::CSV_TYPES.include?(file.content_type)
      respond_to do |format|
        format.html { redirect_to new_session_path, :notice => t('misc.controller.import.upload') }
        format.json { render :json => t('misc.controller.import.upload'), :status => :bad_request, :layout => false }
      end and return
    end

    import = SessionImport.new(
      :uploaded_by => current_user,
      :ranking_id => params[:ranking],
      :category => params[:category],
      :teams => true?(params[:teams]),
      :original_filename => file.original_filename,
      :status => SessionImport::PENDING,
      :enqueued_at => Time.current
    )
    import.session_log = file

    if import.save
      SessionImportJob.perform_later(import.id.to_s)

      # Admins are sent to the panel to watch progress; everyone else (organizers)
      # returns to the home page with a message that doesn't reference a panel
      # they cannot access.
      if user_is_admin?
        redirect_target = admin_session_imports_path
        enqueued_notice = t('rankings.sessions.controller.import.enqueued')
      else
        redirect_target = root_path
        enqueued_notice = t('rankings.sessions.controller.import.enqueued_uploader')
      end

      respond_to do |format|
        format.html do
          redirect_to redirect_target,
                      status: :see_other,
                      notice: enqueued_notice
        end
        format.json { render :json => { :id => import.id.to_s, :status => import.status }, :status => :accepted, :layout => false }
        format.any { head :not_acceptable }
      end and return
    else
      respond_to do |format|
        format.html { redirect_to new_session_path, :notice => import.errors.full_messages.to_sentence }
        format.json { render :json => import.errors, :status => :unprocessable_entity, :layout => false }
      end and return
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_session
    @session = Session.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def session_params
    params.require(:session).permit(:number, :host_name, :version, :physics, :protocol, :pickups, :date,
                                    :category, :teams, :ranking, :session_log)
  end
end

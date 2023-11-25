class SessionsController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :authenticate_staff, :except => [:index, :show]
  before_action :set_session, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /sessions or /sessions.json
  def index
    @sessions = Session.all
    @sessions = Kaminari.paginate_array(@sessions).page(params[:page]).per(1)

    respond_with @sessions do |format|
      format.json { render :layout => false }
    end
  end

  # GET /sessions/1 or /sessions/1.json
  def show
    require 'rva_calculate_results_service'

    @count = 0
    @rva_results = RvaCalculateResultsService.new(@session).call

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
        format.html { redirect_to session_url(@session), :notice => 'Session was successfully created.' }
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
        format.html { redirect_to session_url(@session), :notice => 'Session was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @session, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @session.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # DELETE /sessions/1 or /sessions/1.json
  def destroy
    require 'rva_calculate_results_service'
    require 'stats_service'

    @rva_results = RvaCalculateResultsService.new(@session).call

    StatsService.new(@session, @rva_results).remove_stats unless @session.nil? || @session.teams?

    @session.destroy

    respond_to do |format|
      format.html { redirect_to sessions_url, :notice => 'Session was successfully destroyed.' }
      format.json { head :no_content }
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
  def import
    require 'csv_import_sessions_service'

    file = params[:session_log]

    if file.nil?
      respond_to do |format|
        format.html { redirect_to new_session_path, :notice => 'You must select a CSV file.' }
        format.json { render :json => 'You must select a CSV file.', :status => :bad_request, :layout => false }
      end

      return
    end

    unless SYS::CSV_TYPE.include?(file.content_type)
      respond_to do |format|
        format.html { redirect_to new_session_path, :note => 'You may only upload CSV files.' }
        format.json { render :json => 'You may only upload CSV files.', :status => :bad_request, :layout => false }
      end

      return
    end

    @session = CsvImportSessionsService.new(file, params[:ranking], params[:category], params[:number],
                                            params[:teams]).call

    respond_to do |format|
      if @session.save!
        format.html { redirect_to session_url(@session), :notice => 'Session was successfully imported.' }
        format.json { render :show, :status => :created, :location => @session, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @session.errors, :status => :unprocessable_entity, :layout => false }

        return
      end
    end

    Rails.cache.delete('recent_sessions')

    # NOTE: Rankings are created automatically after a season is saved, therefore the only way to keep them up to date
    # in cache is by expiring their keys for each new session upload.
    Rails.cache.delete('current_ranking')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_session
    @session = Session.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def session_params
    params.require(:session).permit(:number, :host, :version, :physics, :protocol, :pickups, :date,
                                    :category, :teams, :ranking, :session_log)
  end
end

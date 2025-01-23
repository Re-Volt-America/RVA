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
    require 'rva_calculate_results_service'

    @count = 0
    @rva_results = Rails.cache.fetch("Session:#{@session.id}", :expires_in => 1.month) do
      RvaCalculateResultsService.new(@session).call
    end

    # Car usage analysis
    car_rows = @rva_results.each_with_index.select { |row, idx| idx % 2 == 0 && idx >= 2 }.map(&:first)

    @car_usage = car_rows.each_with_object(Hash.new(0)) do |row, hash|
      next unless row[4].is_a?(Array)

      cars = row[4].select { |car| car.is_a?(Car) }
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
    require 'rva_calculate_results_service'
    require 'stats_service'
    require 'team_points_service'

    rva_results = RvaCalculateResultsService.new(@session).call

    if @session.teams?
      TeamPointsService.new(@session, rva_results).remove_team_points
    else
      StatsService.new(@session, rva_results).remove_stats
    end

    respond_to do |format|
      if @session.destroy!
        Rails.cache.delete("Session:#{@session.id}")

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
  def import
    require 'csv_import_sessions_service'

    file = params[:session_log]

    if file.nil?
      respond_to do |format|
        format.html { redirect_to new_session_path, :notice => t('misc.controller.import.select') }
        format.json { render :json => t('misc.controller.import.select'), :status => :bad_request, :layout => false }
      end and return
    end

    unless SYS::CSV_TYPES.include?(file.content_type)
      respond_to do |format|
        format.html { redirect_to new_session_path, :note => t('misc.controller.import.upload') }
        format.json { render :json => t('misc.controller.import.upload'), :status => :bad_request, :layout => false }
      end and return
    end

    @session = CsvImportSessionsService.new(file, params[:ranking], params[:category], params[:number],
                                            params[:teams]).call

    if @session.save
      Rails.cache.delete('recent_sessions')
      Rails.cache.delete('current_ranking')

      respond_to do |format|
        format.html do
          redirect_to session_url(@session),
                      status: :see_other,
                      notice: t('rankings.sessions.controller.import.success')
        end

        format.json { render :show, status: :created, location: @session, layout: false }
        format.any { head :not_acceptable }
      end and return
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity, layout: false }
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
    params.require(:session).permit(:number, :host, :version, :physics, :protocol, :pickups, :date,
                                    :category, :teams, :ranking, :session_log)
  end
end

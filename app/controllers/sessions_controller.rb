class SessionsController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :authenticate_staff, :except => [:index, :show]
  before_action :set_session, only: %i[ show edit update destroy ]

  # GET /sessions or /sessions.json
  def index
    @sessions = Session.all
  end

  # GET /sessions/1 or /sessions/1.json
  def show
    require 'rva_calculate_results_service'

    @rva_results = RvaCalculateResultsService.new(@session).call
  end

  # GET /sessions/new
  def new
    @session = Session.new
    @category_numbers_map = SYS::CATEGORY::NUMBERS_MAP
  end

  # GET /sessions/1/edit
  def edit
  end

  # POST /sessions or /sessions.json
  def create
    @session = Session.new(session_params)

    respond_to do |format|
      if @session.save
        format.html { redirect_to session_url(@session), notice: "Session was successfully created." }
        format.json { render :show, status: :created, location: @session }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sessions/1 or /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to session_url(@session), notice: "Session was successfully updated." }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1 or /sessions/1.json
  def destroy
    @session.destroy

    respond_to do |format|
      format.html { redirect_to sessions_url, notice: "Session was successfully destroyed." }
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

  # FIXME: Selecting no file breaks everything
  # FIXME: Validate if file is empty?
  # @note Physics and other info is only captured for the first race.
  def import
    require 'csv_import_sessions_service'

    file = params[:file]

    # FIXME: This check fails on MacOS, even when using correct .csv files.
    if file.content_type != CsvImportSessionsService::CSV_TYPE
      respond_to do |format|
        format.html { redirect_to new_session_path, :note => "You may only upload CSV files." }
        format.json { render :json => "You may only upload CSV files.", :status => :bad_request }
      end
    end

    @session = CsvImportSessionsService.new(file, params[:ranking], params[:category], params[:teams]).call

    respond_to do |format|
      if @session.save!
        format.html { redirect_to session_url(@session), notice: "Session was successfully imported." }
        format.json { render :show, status: :created, location: @session }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.require(:session).permit(:host, :version, :physics, :protocol, :pickups, :date, :sessionlog, :category, :teams, :ranking)
    end
end

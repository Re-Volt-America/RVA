class SessionsController < ApplicationController
  require "csv"

  CSV_TYPE = "application/vnd.ms-excel".freeze
  XLSM_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze

  before_action :authenticate_user!, :except => [:index, :show]
  before_action :authenticate_staff, :except => [:index, :show]
  before_action :set_session, only: %i[ show edit update destroy ]

  # GET /sessions or /sessions.json
  def index
    @sessions = Session.all
  end

  # GET /sessions/1 or /sessions/1.json
  def show
  end

  # GET /sessions/new
  def new
    @session = Session.new
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
    @rankings = Ranking.where(:season_id => params[:season]).collect {|r| [r.number, r.id]}

    respond_to do |format|
      format.turbo_stream { render :layout => false }
    end
  end

  # FIXME: Selecting no file breaks everything
  # FIXME: Validate if CSV is actually a session log
  # FIXME: Validate if file is empty?
  # @note Physics and other info is only captured for the first race.
  def import
    file = params[:file]

    if file.content_type != CSV_TYPE
      redirect_to new_session_path, :notice => "You may only upload CSV files."
    end

    full_log = []
    session_info = []
    session_races = []
    file = File.open(file)
    csv = CSV.parse(file)

    # @see https://github.com/Re-Volt-America/RVA-Points/blob/f17b2fcf0e66470665622002fcce0207c5652597/rva_points_app/session_log.py#L326
    csv.each do |row|
      full_log << row
    end

    host = full_log[1][2]
    version = full_log[0][1]
    physics = full_log[1][3]
    protocol = full_log[0][2]
    date = Date.strptime(full_log[1][1], "%D")
    pickups = true?(full_log[1][5])

    races = []
    full_log.drop(2).each do |row|

    end



    byebug
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.require(:session).permit(:host, :version, :physics, :protocol, :pickups, :date, :sessionlog, :teams, :ranking)
    end
end

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

    file = File.open(file)
    csv = CSV.parse(file)

    full_log = []
    session_info = []
    session_races_arr = []

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

    first = true
    race = []
    racers = []

    full_log.drop(2).each do |row|
      if row[0] == "#" # skip headers
        next
      end

      if not first and row[0] == "Results"
        race << racers
        session_races_arr << race
        race = []
        racers = []
        race << row
      else
        if row[0] == "Results"
            race << row
        else
            racers << row
        end

        first = false
      end
    end

    sample_car = Car.first.as_json

    races = []
    session_races_arr.each do |race_arr|
      track_hash = Track.first.as_json # object hash
      racers_count = race_arr[0][2]

      count = 0
      racer_entries = {}
      race_arr[1].each do |racer_arr|
        racer_entry_hash = {}
        racer_entry_hash[:position] = racer_arr[0]
        racer_entry_hash[:name] = racer_arr[1]
        racer_entry_hash[:car] = sample_car # FIXME: look for the exact car...
        racer_entry_hash[:time] = racer_arr[3]
        racer_entry_hash[:best_lap] = racer_arr[4]
        racer_entry_hash[:finished] = true?(racer_arr[5])
        racer_entry_hash[:cheating] = true?(racer_arr[6])

        racer_entries = racer_entries.merge(count.to_s => racer_entry_hash)
        count += 1
      end

      race_hash = {}
      race_hash[:track] = track_hash
      race_hash[:racer_entries] = racer_entries
      race_hash[:laps] = 3 # FIXME: look for real lap counts
      race_hash[:racers_count] = racers_count

      races << Race.new(race_hash) # FIXME: add missing fields (created_at, updated_at, etc...)
    end

    # TODO: new Session(session_hash)

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

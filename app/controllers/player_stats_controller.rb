class PlayerStatsController < ApplicationController
  before_action :set_player_stat, only: %i[ show edit update destroy ]

  # GET /player_stats or /player_stats.json
  def index
    @player_stats = PlayerStat.all
  end

  # GET /player_stats/1 or /player_stats/1.json
  def show
  end

  # GET /player_stats/new
  def new
    @player_stat = PlayerStat.new
  end

  # GET /player_stats/1/edit
  def edit
  end

  # POST /player_stats or /player_stats.json
  def create
    @player_stat = PlayerStat.new(player_stat_params)

    respond_to do |format|
      if @player_stat.save
        format.html { redirect_to player_stat_url(@player_stat), notice: "Player stat was successfully created." }
        format.json { render :show, status: :created, location: @player_stat }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /player_stats/1 or /player_stats/1.json
  def update
    respond_to do |format|
      if @player_stat.update(player_stat_params)
        format.html { redirect_to player_stat_url(@player_stat), notice: "Player stat was successfully updated." }
        format.json { render :show, status: :ok, location: @player_stat }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /player_stats/1 or /player_stats/1.json
  def destroy
    @player_stat.destroy

    respond_to do |format|
      format.html { redirect_to player_stats_url, notice: "Player stat was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player_stat
      @player_stat = PlayerStat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_stat_params
      params.require(:player_stat).permit(:race_wins, :race_count, :average_position, :participation_rate, :official_score, :obtained_points, :team_points)
    end
end

class RacesController < ApplicationController
  before_action :set_race, only: %i[ show edit update destroy ]

  # GET /races or /races.json
  def index
    @races = Race.all
  end

  # GET /races/1 or /races/1.json
  def show
  end

  # GET /races/new
  def new
    @race = Race.new
  end

  # GET /races/1/edit
  def edit
  end

  # POST /races or /races.json
  def create
    @race = Race.new(race_params)

    respond_to do |format|
      if @race.save
        format.html { redirect_to race_url(@race), notice: "Race was successfully created." }
        format.json { render :show, status: :created, location: @race }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /races/1 or /races/1.json
  def update
    respond_to do |format|
      if @race.update(race_params)
        format.html { redirect_to race_url(@race), notice: "Race was successfully updated." }
        format.json { render :show, status: :ok, location: @race }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /races/1 or /races/1.json
  def destroy
    @race.destroy

    respond_to do |format|
      format.html { redirect_to races_url, notice: "Race was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race
      @race = Race.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def race_params
      params.require(:race).permit(:track, :racers_count)
    end
end

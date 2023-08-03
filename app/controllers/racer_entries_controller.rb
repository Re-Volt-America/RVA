class RacerEntriesController < ApplicationController
  before_action :set_racer_entry, only: %i[ show edit update destroy ]

  # GET /racer_entries or /racer_entries.json
  def index
    @racer_entries = RacerEntry.all
  end

  # GET /racer_entries/1 or /racer_entries/1.json
  def show
  end

  # GET /racer_entries/new
  def new
    @racer_entry = RacerEntry.new
  end

  # GET /racer_entries/1/edit
  def edit
  end

  # POST /racer_entries or /racer_entries.json
  def create
    @racer_entry = RacerEntry.new(racer_entry_params)

    respond_to do |format|
      if @racer_entry.save
        format.html { redirect_to racer_entry_url(@racer_entry), notice: "Racer entry was successfully created." }
        format.json { render :show, status: :created, location: @racer_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @racer_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /racer_entries/1 or /racer_entries/1.json
  def update
    respond_to do |format|
      if @racer_entry.update(racer_entry_params)
        format.html { redirect_to racer_entry_url(@racer_entry), notice: "Racer entry was successfully updated." }
        format.json { render :show, status: :ok, location: @racer_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @racer_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /racer_entries/1 or /racer_entries/1.json
  def destroy
    @racer_entry.destroy

    respond_to do |format|
      format.html { redirect_to racer_entries_url, notice: "Racer entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_racer_entry
      @racer_entry = RacerEntry.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def racer_entry_params
      params.require(:racer_entry).permit(:position, :username, :time, :best_lap, :finished, :cheating, :car, :team)
    end
end

class SeasonsController < ApplicationController
  before_action :authenticate_user!, :only => [:edit, :update, :destroy]
  before_action :authenticate_admin, :only => [:edit, :update, :destroy]
  before_action :set_season, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /seasons or /seasons.json
  def index
    @seasons = Season.all

    respond_with @seasons do |format|
      format.json { render :layout => false }
    end
  end

  # GET /seasons/1 or /seasons/1.json
  def show
    @count = 1
    @entries = @season.racer_result_entries

    respond_with @season do |format|
      format.json { render :layout => false }
    end
  end

  # GET /seasons/new
  def new
    @season = Season.new
  end

  # GET /seasons/1/edit
  def edit; end

  # POST /seasons or /seasons.json
  def create
    @season = Season.new(season_params)

    Rails.cache.delete('current_season')

    respond_to do |format|
      if @season.save!
        6.times do |n|
          @season.rankings << Ranking.new({ :number => n + 1, :season => @season })
        end

        format.html { redirect_to season_url(@season), :notice => 'Season was successfully created.' }
        format.json { render :show, :status => :created, :location => @season, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @season.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /seasons/1 or /seasons/1.json
  def update
    respond_to do |format|
      if @season.update(season_params)
        format.html { redirect_to season_url(@season), :notice => 'Season was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @season, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @season.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # DELETE /seasons/1 or /seasons/1.json
  def destroy
    @season.rankings.each(&:destroy)

    @season.destroy

    respond_to do |format|
      format.html { redirect_to seasons_url, :notice => 'Season was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_season
    @season = Season.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def season_params
    params.require(:season).permit(:name, :start_date, :end_date)
  end
end

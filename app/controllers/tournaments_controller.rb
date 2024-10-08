class TournamentsController < ApplicationController
  before_action :authenticate_user!, :only => [:edit, :update, :destroy]
  before_action :authenticate_admin, :only => [:edit, :update, :destroy]
  before_action :set_tournament, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /tournaments or /tournaments.json
  def index
    @tournaments = Tournament.all

    respond_with @tournaments do |format|
      format.json { render :layout => false }
    end
  end

  # GET /tournaments/1 or /tournaments/1.json
  def show
    respond_with @tournament do |format|
      format.json { render :layout => false }
    end
  end

  # GET /tournaments/new
  def new
    @tournament = Tournament.new
  end

  # GET /tournaments/1/edit
  def edit; end

  # POST /tournaments or /tournaments.json
  def create
    @tournament = Tournament.new(tournament_params)

    respond_to do |format|
      if @tournament.save
        format.html { redirect_to tournament_url(@tournament), :notice => t('.controller.create') }
        format.json { render :show, :status => :created, :location => @tournament, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @tournament.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /tournaments/1 or /tournaments/1.json
  def update
    respond_to do |format|
      if @tournament.update(tournament_params)
        format.html { redirect_to tournament_url(@tournament), :notice => t('.controller.update') }
        format.json { render :show, :status => :ok, :location => @tournament, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @tournament.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # DELETE /tournaments/1 or /tournaments/1.json
  def destroy
    @tournament.destroy

    respond_to do |format|
      format.html { redirect_to tournaments_url, :notice => t('.controller.destroy') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def tournament_params
    params.require(:tournament).permit(:name, :date, :format, :season, :tournament_banner)
  end
end

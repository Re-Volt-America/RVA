class RankingsController < ApplicationController
  before_action :authenticate_user!, :only => [:edit, :update, :destroy]
  before_action :authenticate_admin, :only => [:edit, :update, :destroy]
  before_action :set_ranking, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /rankings.json
  def index
    @rankings = Ranking.all

    respond_with @rankings do |format|
      format.json { render :layout => false }
    end
  end

  # GET /rankings/1 or /rankings/1.json
  def show
    @sessions = @ranking.sessions.reverse!
    @sessions = Kaminari.paginate_array(@sessions).page(params[:page]).per(8)

    @racer_entries = @ranking.racer_result_entries
    @count = 1

    @team_entries = @ranking.team_result_entries.order_by(points: :desc)

    respond_with @ranking do |format|
      format.json { render :layout => false }
    end
  end

  # GET /rankings/new
  def new
    @ranking = Ranking.new
  end

  # GET /rankings/1/edit
  def edit; end

  # POST /rankings or /rankings.json
  def create
    @ranking = Ranking.new(ranking_params)

    respond_to do |format|
      if @ranking.save
        format.html { redirect_to ranking_url(@ranking), :notice => t('.controller.create') }
        format.json { render :show, :status => :created, :location => @ranking, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @ranking.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /rankings/1 or /rankings/1.json
  def update
    respond_to do |format|
      if @ranking.update(ranking_params)
        format.html { redirect_to ranking_url(@ranking), :notice => t('.controller.update') }
        format.json { render :show, :status => :ok, :location => @ranking }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @ranking.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # DELETE /rankings/1 or /rankings/1.json
  def destroy
    respond_to do |format|
      if @ranking.destroy!
        format.html { redirect_to rankings_url, :notice => t('.controller.delete') }
        format.json { head :no_content }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @ranking.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ranking
    @ranking = Ranking.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ranking_params
    params.require(:ranking).permit(:number, :season)
  end
end

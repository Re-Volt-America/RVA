class TeamsController < ApplicationController
  before_action :authenticate_user!, :only => [:edit, :update, :destroy]
  before_action :authenticate_admin, :only => [:edit, :update, :destroy]
  before_action :set_team, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /teams or /teams.json
  def index
    @teams = Team.all
    @sorted_teams = Team.all.sort_by(&:points).reverse!

    respond_with @teams do |format|
      format.json { render :layout => false }
    end
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # GET /teams/1/edit
  def edit; end

  # POST /teams or /teams.json
  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to teams_path, :notice => 'Team was successfully created.' }
        format.json { render :show, :status => :created, :location => @team, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @team.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /teams/1 or /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to teams_path, :notice => 'Team was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @team, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @team.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # GET /teams/1 or /teams/1.json
  def show
    @leader = @team.leader
    @members = @team.members

    respond_with @team do |format|
      format.json { render :layout => false }
    end
  end

  # DELETE /teams/1 or /teams/1.json
  def destroy
    @team.destroy

    respond_to do |format|
      format.html { redirect_to teams_url, :notice => 'Team was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def team_params
    params.require(:team).permit(:name, :short_name, :color, :team_logo, :points, :leader, :members)
  end
end

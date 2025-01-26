class TeamsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  before_action :authenticate_mod, :except => [:show, :index]
  before_action :set_team, :only => [:show, :edit, :update, :add_member, :destroy]

  respond_to :html, :json

  # GET /teams or /teams.json
  def index
    @teams = Team.all
    @sorted_teams = @teams.order_by(points: :desc)

    respond_with @teams do |format|
      format.json { render :layout => false }
    end
  end

  # GET /teams/new
  def new
    @team = Team.new
    @no_team_users = User.all.filter { |u| u.team_id.nil? }
  end

  # GET /teams/1/edit
  def edit
    @sorted_members = @team.members.sort_by { |u| u.username.downcase }

    # NOTE: Select leader by default
    @sorted_members.insert(0, @sorted_members.delete(@team.leader))
  end

  # POST /teams or /teams.json
  def create
    @team = Team.new(team_params)
    @team.members << @team.leader
    @team.leader.save!

    respond_to do |format|
      if @team.save
        format.html { redirect_to teams_path, :notice => t('.controller.create') }
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
        format.html { redirect_to team_path(@team), :notice => t('.controller.update') }
        format.json { render :show, :status => :ok, :location => @team, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @team.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  def add_member
    new_member = User.find_by(:id => params[:member])
    @team.members << new_member

    respond_to do |format|
      if @team.update!
        format.html do
          redirect_to team_path(@team),
                      :notice => t('.controller.add-member', :member => new_member.username, :team => @team.name)
        end
      else
        format.html { redirect_to team_path(@team), :status => :unprocessable_entity }
      end
    end
  end

  # GET /teams/1 or /teams/1.json
  def show
    @leader = @team.leader

    @members = @team.members.filter { |m| !m.username.eql?(@leader.username) }

    @no_team_users = User.all.filter { |u| u.team_id.nil? }

    respond_with @team do |format|
      format.json { render :layout => false }
    end
  end

  # DELETE /teams/1 or /teams/1.json
  def destroy
    @team.destroy

    respond_to do |format|
      format.html { redirect_to teams_url, :notice => t('.controller.destroy') }
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

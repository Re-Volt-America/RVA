class StatsController < ApplicationController
  before_action :set_stat, :only => [:show, :edit, :update, :destroy]

  # GET /stats or /stats.json
  def index
    @stats = Stats.all
  end

  # GET /stats/1 or /stats/1.json
  def show; end

  # GET /stats/new
  def new
    @stat = Stats.new
  end

  # GET /stats/1/edit
  def edit; end

  # POST /stats or /stats.json
  def create
    @stat = Stats.new(stat_params)

    respond_to do |format|
      if @stat.save
        format.html { redirect_to stat_url(@stat), :notice => 'Stats was successfully created.' }
        format.json { render :show, :status => :created, :location => @stat }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stats/1 or /stats/1.json
  def update
    respond_to do |format|
      if @stat.update(stat_params)
        format.html { redirect_to stat_url(@stat), :notice => 'Stats was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @stat }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stats/1 or /stats/1.json
  def destroy
    @stat.destroy

    respond_to do |format|
      format.html { redirect_to stats_index_url, :notice => 'Stats was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stat
    @stat = Stats.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def stat_params
    params.fetch(:stat, {})
  end
end

class WeeklySchedulesController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :authenticate_organizer, :except => [:index, :show]
  before_action :set_weekly_schedule, :only => [:show, :edit, :update, :destroy]

  # GET /weekly_schedules or /weekly_schedules.json
  def index
    @weekly_schedules = WeeklySchedule.all
    @count = 1
  end

  # GET /weekly_schedules/1 or /weekly_schedules/1.json
  def show
    @count = 0
    @table_count = 0
  end

  # GET /weekly_schedules/new
  def new
    @weekly_schedule = WeeklySchedule.new
  end

  # GET /weekly_schedules/1/edit
  def edit
  end

  # POST /weekly_schedules or /weekly_schedules.json
  def create
    require 'rva_generate_weekly_schedule_service'

    @weekly_schedule = RvaGenerateWeeklyScheduleService.new(weekly_schedule_params).generate

    respond_to do |format|
      if @weekly_schedule.save
        format.html { redirect_to weekly_schedule_url(@weekly_schedule), :notice => "Weekly schedule was successfully created." }
        format.json { render :show, :status => :created, :location => @weekly_schedule }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @weekly_schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weekly_schedules/1 or /weekly_schedules/1.json
  def update
    respond_to do |format|
      if @weekly_schedule.update(weekly_schedule_params)
        format.html { redirect_to weekly_schedule_url(@weekly_schedule), :notice => "Weekly schedule was successfully updated." }
        format.json { render :show, :status => :ok, :location => @weekly_schedule }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @weekly_schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_schedules/1 or /weekly_schedules/1.json
  def destroy
    @weekly_schedule.destroy!

    respond_to do |format|
      format.html { redirect_to weekly_schedules_url, :notice => "Weekly schedule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weekly_schedule
      @weekly_schedule = WeeklySchedule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def weekly_schedule_params
      params.require(:weekly_schedule).permit(:season, :start_date)
    end
end

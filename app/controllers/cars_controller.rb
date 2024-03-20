class CarsController < ApplicationController
  include CarsHelper

  before_action :authenticate_user!, :only => [:edit, :update, :destroy]
  before_action :authenticate_admin, :only => [:edit, :update, :destroy]
  before_action :set_car, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /cars or /cars.json
  def index
    @cars = Car.all

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/rookie or /cars/rookie.json
  def rookie
    @cars = Rails.cache.fetch('rookie_cars', :expires_in => 1.month) do
      @cars = cars_of_category(SYS::CATEGORY::ROOKIE)
    end

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/amateur or /cars/amateur.json
  def amateur
    @cars = Rails.cache.fetch('amateur_cars', :expires_in => 1.month) do
      @cars = cars_of_category(SYS::CATEGORY::AMATEUR)
    end

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/advanced or /cars/advanced.json
  def advanced
    @cars = Rails.cache.fetch('advanced_cars', :expires_in => 1.month) do
      @cars = cars_of_category(SYS::CATEGORY::ADVANCED)
    end

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/semipro or /cars/semipro.json
  def semipro
    @cars = Rails.cache.fetch('semipro_cars', :expires_in => 1.month) do
      @cars = cars_of_category(SYS::CATEGORY::SEMI_PRO)
    end

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/pro or /cars/pro.json
  def pro
    @cars = Rails.cache.fetch('pro_cars', :expires_in => 1.month) do
      @cars = cars_of_category(SYS::CATEGORY::PRO)
    end

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/superpro or /cars/superpro.json
  def superpro
    @cars = Rails.cache.fetch('superpro_cars', :expires_in => 1.month) do
      @cars = cars_of_category(SYS::CATEGORY::SUPER_PRO)
    end

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/clockwork or /cars/clockwork.json
  def clockwork
    @cars = Rails.cache.fetch('clockwork_cars', :expires_in => 1.month) do
      @cars = cars_of_category(SYS::CATEGORY::CLOCKWORK)
    end

    respond_with @cars do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/1 or /cars/1.json
  def show
    respond_with @car do |format|
      format.json { render :layout => false }
    end
  end

  # GET /cars/new
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  def edit; end

  # POST /cars or /cars.json
  def create
    @car = Car.new(car_params)

    respond_to do |format|
      if @car.save!
        format.html { redirect_to car_url(@car), :notice => t("rva.cars.controller.create") }
        format.json { render :show, :status => :created, :location => @car, :layout => false }

        Rails.cache.delete(category_cache_key(params[:category]))
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @car.errors, :status => :unprocessable_entity, :layout => false }
      end and return
    end
  end

  # PATCH/PUT /cars/1 or /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        format.html { redirect_to car_url(@car), :notice => t("rva.cars.controller.update") }
        format.json { render :show, :status => :ok, :location => @car, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @car.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  def import
    require 'csv_import_cars_service'

    file = params[:file]
    if file.nil?
      respond_to do |format|
        format.html { redirect_to new_car_path, :notice => t("shared.controller.import.select") }
        format.json { render :json => t("shared.controller.import.select"), :status => :bad_request, :layout => false }
      end and return
    end

    unless SYS::CSV_TYPES.include?(file.content_type)
      respond_to do |format|
        format.html { redirect_to new_car_path, :notice => t("shared.controller.import.upload") }
        format.json { render :json => t("shared.controller.import.upload"), :status => :bad_request, :layout => false }
      end and return
    end

    if params[:season].nil? || params[:season].empty?
      respond_to do |format|
        format.html { redirect_to new_car_path, :notice => t("shared.controller.import.season") }
        format.json { render :json => 'You must select a Season.', :status => :bad_request, :layout => false }
      end and return
    end

    if params[:category].nil? || params[:category].empty?
      respond_to do |format|
        format.html { redirect_to new_car_path, :notice => t("shared.controller.import.category") }
        format.json { render :json => t("shared.controller.import.category"), :status => :bad_request, :layout => false }
      end and return
    end

    @cars = CsvImportCarsService.new(file, params[:season], params[:category]).call

    respond_to do |format|
      if @cars.empty?
        format.html { redirect_to new_car_path, :notice => t("rva.cars.controller.import.exists") }
        format.json { render :show, :status => :ok, :layout => false }
      end and return

      @cars.each do |car|
        if car.save!
          format.html { redirect_to new_car_path, :notice => t("rva.cars.controller.import.success") }
          format.json { render :show, :status => :created, :location => car, :layout => false }

          Rails.cache.delete(category_cache_key(params[:category].to_i))
        else
          format.html { render :new, :status => :unprocessable_entity }
          format.json { render :json => car.errors, :status => :unprocessable_entity, :layout => false }
        end
      end
    end
  end

  # DELETE /cars/1 or /cars/1.json
  def destroy
    @car.destroy

    respond_to do |format|
      format.html { redirect_to cars_url, :notice => t("rva.cars.controller.destroy") }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_car
    @car = Car.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def car_params
    params.require(:car).permit(:name, :speed, :accel, :weight, :multiplier, :folder_name, :category, :stock, :season)
  end
end

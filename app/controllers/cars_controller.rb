class CarsController < ApplicationController
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

  # GET /cars/1 or /cars/hash.json
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
      if @car.save
        format.html { redirect_to car_url(@car), :notice => 'Car was successfully created.' }
        format.json { render :show, :status => :created, :location => @car, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @car.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /cars/1 or /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        format.html { redirect_to car_url(@car), :notice => 'Car was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @car, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @car.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # DELETE /cars/1 or /cars/1.json
  def destroy
    @car.destroy

    respond_to do |format|
      format.html { redirect_to cars_url, :notice => 'Car was successfully destroyed.' }
      format.json { head :no_content, :layout => false }
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

class CarRatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_car

  # POST /cars/:car_id/rating
  def create
    @car_rating = CarRating.find_or_initialize_by(:car_id => @car.id, :user_id => current_user.id)
    @car_rating.assign_attributes(car_rating_params)

    respond_to do |format|
      if @car_rating.save
        format.turbo_stream { render :locals => { :saved => true } }
        format.html { redirect_to car_path(@car), :notice => t('rva.cars.rating.controller.success') }
      else
        format.turbo_stream { render :locals => { :saved => false } }
        format.html { redirect_to car_path(@car), :notice => t('rva.cars.rating.controller.failure') }
      end
    end
  end

  private

  def set_car
    @car = Car.find(params[:car_id])
  end

  def car_rating_params
    params.require(:car_rating).permit(:handling_rating, :visuals_rating, :audio_rating, :fun_rating)
  end
end

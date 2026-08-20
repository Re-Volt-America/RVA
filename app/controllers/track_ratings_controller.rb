class TrackRatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_track

  # POST /tracks/:track_id/rating
  def create
    @track_rating = TrackRating.find_or_initialize_by(:track_id => @track.id, :user_id => current_user.id)
    @track_rating.assign_attributes(track_rating_params)

    respond_to do |format|
      if @track_rating.save
        format.turbo_stream { render :locals => { :saved => true } }
        format.html { redirect_to track_path(@track), :notice => t('rva.tracks.rating.controller.success') }
      else
        format.turbo_stream { render :locals => { :saved => false } }
        format.html { redirect_to track_path(@track), :notice => t('rva.tracks.rating.controller.failure') }
      end
    end
  end

  private

  def set_track
    @track = Track.find(params[:track_id])
  end

  def track_rating_params
    params.require(:track_rating).permit(:gameplay_rating, :visuals_rating, :audio_rating, :fun_rating)
  end
end

class TracksController < ApplicationController
  before_action :authenticate_user!, :only => [:edit, :update, :destroy]
  before_action :authenticate_admin, :only => [:edit, :update, :destroy]
  before_action :set_track, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /tracks or /tracks.json
  def index
    @tracks = Track.all
    @tracks = Kaminari.paginate_array(@tracks).page(params[:page]).per(12)

    respond_with @tracks do |format|
      format.json { render :layout => false }
    end
  end

  # GET /tracks/1 or /tracks/1.json
  def show
    respond_with @track do |format|
      format.json { render :layout => false }
    end
  end

  # GET /tracks/new
  def new
    @track = Track.new
  end

  # GET /tracks/1/edit
  def edit; end

  # POST /tracks or /tracks.json
  def create
    @track = Track.new(track_params)

    respond_to do |format|
      if @track.save
        format.html { redirect_to track_url(@track), :notice => 'Track was successfully created.' }
        format.json { render :show, :status => :created, :location => @track, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @track.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /tracks/1 or /tracks/1.json
  def update
    respond_to do |format|
      if @track.update(track_params)
        format.html { redirect_to track_url(@track), :notice => 'Track was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @track, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @track.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  def import
    require 'csv_import_tracks_service'

    file = params[:file]

    if file.content_type != SYS::CSV_TYPE
      respond_to do |format|
        format.html { redirect_to new_car_path, :note => 'You may only upload CSV files.' }
        format.json { render :json => 'You may only upload CSV files.', :status => :bad_request, :layout => false }
      end

      return
    end

    @tracks = CsvImportTracksService.new(file, params[:season]).call

    respond_to do |format|
      @tracks.each do |track|
        if track.save!
          format.html { redirect_to tracks_path, :notice => 'Tracks successfully imported.' }
          format.json { render :show, :status => :created, :location => track, :layout => false }
        else
          format.html { render :new, :status => :unprocessable_entity }
          format.json { render :json => track.errors, :status => :unprocessable_entity, :layout => false }
        end
      end
    end
  end

  # DELETE /tracks/1 or /tracks/1.json
  def destroy
    @track.destroy

    respond_to do |format|
      format.html { redirect_to tracks_url, :notice => 'Track was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_track
    @track = Track.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def track_params
    params.require(:track).permit(:name, :short_name, :difficulty, :length, :folder_name, :season)
  end
end

class SeasonsController < ApplicationController
  before_action :authenticate_user!, :only => [:edit, :update, :destroy, :admin_stats]
  before_action :authenticate_admin, :only => [:edit, :update, :destroy, :admin_stats]
  before_action :set_season, :only => [:show, :edit, :update, :destroy]

  respond_to :html, :json

  # GET /seasons or /seasons.json
  def index
    @seasons = Season.all.reverse

    respond_with @seasons do |format|
      format.json { render :layout => false }
    end
  end

  # GET /seasons/1 or /seasons/1.json
  def show
    @racer_entries = @season.racer_result_entries
    @racer_entries = Kaminari.paginate_array(@racer_entries).page(params[:page]).per(16)
    @count = ((@racer_entries.current_page - 1) * @racer_entries.limit_value) + 1

    @team_entries = @season.team_result_entries.order_by(points: :desc)
    @season_stats_filters = season_stats_filter_params
    @season_car_category_options = SYS::CATEGORY::RVGL_NUMBERS_MAP.map { |name, value| [name.to_s, value] }
    @season_car_usage = build_season_car_usage(@season, @season_stats_filters)

    respond_with @season do |format|
      format.json { render :layout => false }
    end
  end

  # GET /admin/seasons/stats
  def admin_stats
    @seasons = Season.all.reverse
    @season = if params[:season_id].present?
                Season.where(:id => params[:season_id]).first || current_season
              else
                current_season
              end

    @season_stats_filters = season_stats_filter_params
    @season_car_category_options = SYS::CATEGORY::RVGL_NUMBERS_MAP.map { |name, value| [name.to_s, value] }
    @season_car_usage = @season.nil? ? {} : build_season_car_usage(@season, @season_stats_filters)
  end

  # GET /seasons/new
  def new
    @season = Season.new
  end

  # GET /seasons/1/edit
  def edit; end

  # POST /seasons or /seasons.json
  def create
    @season = Season.new(season_params)

    respond_to do |format|
      if @season.save
        6.times do |n|
          @season.rankings << Ranking.new({ :number => n + 1, :season => @season })
        end

        Rails.cache.delete('current_season')

        Rails.cache.delete('rookie_cars')
        Rails.cache.delete('amateur_cars')
        Rails.cache.delete('advanced_cars')
        Rails.cache.delete('semipro_cars')
        Rails.cache.delete('pro_cars')
        Rails.cache.delete('superpro_cars')
        Rails.cache.delete('clockwork_cars')

        format.html { redirect_to season_url(@season), :notice => t('.controller.create') }
        format.json { render :show, :status => :created, :location => @season, :layout => false }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @season.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # PATCH/PUT /seasons/1 or /seasons/1.json
  def update
    respond_to do |format|
      if @season.update(season_params)
        format.html { redirect_to season_url(@season), :notice => t('.controller.update') }
        format.json { render :show, :status => :ok, :location => @season, :layout => false }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @season.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  # DELETE /seasons/1 or /seasons/1.json
  def destroy
    require 'stats_service'
    require 'team_points_service'

    @season.rankings.each do |r|
      r.sessions.each do |s|
        if s.teams?
          TeamPointsService.new(s).remove_team_points
        else
          StatsService.new(s).remove_stats
        end

        s.destroy!
      end

      r.destroy!
    end

    @season.tracks.each(&:destroy)
    @season.cars.each(&:destroy)

    respond_to do |format|
      if @season.destroy!
        format.html { redirect_to seasons_url, :notice => t('.controller.destroy') }
        format.json { head :no_content }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @season.errors, :status => :unprocessable_entity, :layout => false }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_season
    @season = Season.find(params[:id])
  end

  def build_season_car_usage(season, filters)
    usage = Hash.new(0)
    season_cars_by_name = season.cars.to_a.group_by { |car| car.name.to_s.downcase }

    season.rankings.each do |ranking|
      ranking.sessions.each do |session|
        next unless include_session_by_date?(session, filters)

        merge_session_car_usage!(usage, session, filters, season_cars_by_name)
      end
    end

    usage.sort_by { |_, count| -count }.to_h
  end

  def merge_session_car_usage!(usage, session, filters, season_cars_by_name)
    session.races.each do |race|
      race.racer_entries.each do |entry|
        car_name = entry.car_name.to_s.strip
        next if car_name.blank?
        next if car_name.start_with?('!')
        next if car_name.match?(/\Ax+\z/i)
        next unless include_car_by_category?(entry, car_name, filters, season_cars_by_name)

        usage[car_name] += 1
      end
    end
  end

  def season_stats_filter_params
    from_date = parse_filter_date(params[:from_date])
    to_date = parse_filter_date(params[:to_date])

    if from_date && to_date && from_date > to_date
      from_date, to_date = to_date, from_date
    end

    {
      :from_date => from_date,
      :to_date => to_date,
      :car_category => parse_filter_category(params[:car_category]),
      :from_date_value => from_date&.strftime('%Y-%m-%d') || params[:from_date].to_s,
      :to_date_value => to_date&.strftime('%Y-%m-%d') || params[:to_date].to_s,
      :car_category_value => params[:car_category].to_s
    }
  end

  def parse_filter_date(date_param)
    return nil if date_param.blank?

    Date.parse(date_param.to_s)
  rescue ArgumentError
    nil
  end

  def parse_filter_category(category_param)
    return nil if category_param.blank?

    category = Integer(category_param)
    SYS::CATEGORY::RVGL_NUMBERS_MAP.values.include?(category) ? category : nil
  rescue ArgumentError, TypeError
    nil
  end

  def include_session_by_date?(session, filters)
    session_date = session.date&.to_date
    return false if session_date.nil?
    return false if filters[:from_date] && session_date < filters[:from_date]
    return false if filters[:to_date] && session_date > filters[:to_date]

    true
  end

  def include_car_by_category?(entry, car_name, filters, season_cars_by_name)
    return true if filters[:car_category].nil?

    entry_category = entry.car&.category
    return entry_category == filters[:car_category] unless entry_category.nil?

    candidates = season_cars_by_name[car_name.downcase] || []
    candidates.any? { |car| car.category == filters[:car_category] }
  end

  # Only allow a list of trusted parameters through.
  def season_params
    params.require(:season).permit(:name, :start_date, :end_date)
  end
end

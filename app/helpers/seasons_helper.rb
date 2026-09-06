module SeasonsHelper
  # @return The most recent season, or nil if there are no seasons in the system
  def current_season
    return @current_season if defined?(@current_season)

    @current_season = Season.order_by(:start_date => :desc).first
  end

  # @return The season currently in context: the one identified by the :season
  #   param when present and valid, otherwise the latest (current) season.
  def selected_season
    return current_season if params[:season].blank?

    Season.where(:id => params[:season]).first || current_season
  end

  # Appends the season name to a section title (e.g. "The RVA Cars" ->
  # "The RVA Cars of Season 12"). Returns the bare title when no season applies.
  def title_with_season(title, season = selected_season)
    return title if season.nil?

    t('seasons.of-season', :title => title, :season => season.name)
  end
end

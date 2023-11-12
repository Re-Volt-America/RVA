module SeasonsHelper

  # @return The most recent season, or nil if there are no seasons in the system
  def current_season
    Season.all.max_by { |s| s[:start_date] }
  end
end

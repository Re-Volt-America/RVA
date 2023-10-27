module SeasonsHelper

  # TODO: Maybe sort by date?
  def current_season
    Season.first
  end
end

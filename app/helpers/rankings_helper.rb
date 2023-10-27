module RankingsHelper
  include SeasonsHelper

  # TODO: Maybe sort?
  def current_ranking
    return nil if current_season.nil?

    current_season.rankings.first
  end
end

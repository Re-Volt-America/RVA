module RankingsHelper
  include SeasonsHelper

  # @return [Ranking] The ranking currently being played in RVA
  def current_ranking
    return @current_ranking if defined?(@current_ranking)

    season = current_season
    return @current_ranking = nil if season.nil?

    @current_ranking = season.rankings.find { |r| r.sessions.size < 28 }
  end
end

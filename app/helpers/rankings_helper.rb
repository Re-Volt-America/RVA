module RankingsHelper
  include SeasonsHelper

  # @return [Ranking] The ranking currently being played in RVA
  def current_ranking
    season = current_season
    return nil if season.nil?

    current_ranking = nil
    season.rankings.each do |r|
      next if r.sessions.size >= 28

      current_ranking = r
      break
    end

    current_ranking
  end
end

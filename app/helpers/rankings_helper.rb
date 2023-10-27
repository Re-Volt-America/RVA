module RankingsHelper
  include SeasonsHelper

  # TODO: Maybe sort?
  def current_ranking
    if current_season.nil?
      return nil
    end

    current_season.rankings.first
  end
end

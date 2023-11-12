module RankingsHelper
  include SeasonsHelper

  # @return The most recent ranking, or nil if not found
  def current_ranking
    return nil if current_season.nil?

    current_season.rankings.max_by { |s| s[:number] }
  end
end

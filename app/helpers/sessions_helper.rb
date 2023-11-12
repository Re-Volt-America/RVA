module SessionsHelper
  include RankingsHelper

  def latest_session
    nil if current_ranking.nil?

    current_ranking.sessions.last
  end
end

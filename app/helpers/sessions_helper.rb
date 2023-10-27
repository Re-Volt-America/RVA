module SessionsHelper
  include RankingsHelper

  # TODO: Maybe sort?
  def latest_session
    nil if current_ranking.nil?

    current_ranking.sessions.first
  end
end

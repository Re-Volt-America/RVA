module SessionsHelper
  include RankingsHelper

  # TODO: Maybe sort?
  def latest_session
    if current_ranking.nil?
      nil
    end

    current_ranking.sessions.first
  end
end

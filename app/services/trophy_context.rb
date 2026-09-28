# frozen_string_literal: true

# The object passed to every trophy condition. It answers the questions a
# trophy definition needs ("has this user won 10 sessions?", "did they ever
# win a session driving the Mouse?", ...) against the user's current full
# history. That makes trophy evaluation self-consistent: it can run after every
# session import or as a full backfill and always reach the same conclusion.
#
# We can add new helpers here as we invent new kinds of trophies. The point of this
# class is that trophy definitions stay tiny and declarative while the "how do
# we know?" logic lives in one place.
class TrophyContext
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # --- Stat thresholds ------------------------------------------------------

  # Reads a field off the user's embedded Stats document (race_wins,
  # session_wins, session_podiums, race_podiums, session_count, ...).
  # @return [Numeric, nil]
  def stat(name)
    user.stats&.public_send(name)
  end

  # --- Session-based helpers ------------------------------------------------

  # Every session this user has taken part in.
  def sessions
    @sessions ||= Session.where('racer_result_entries.username' => user.username).to_a
  end

  # The sessions this user *won* (finished 1st overall, i.e. top official score).
  def won_sessions
    @won_sessions ||= sessions.select { |session| session_winner(session) == user.username }
  end

  def session_win_count
    won_sessions.size
  end

  # Did the user ever win a session while driving a car with the given name in
  # EVERY race of that session they took part in? (They must have at least one
  # entry, and all of their entries must use the car.) Matching is
  # case-insensitive.
  def won_session_with_car?(car_name)
    target = car_name.to_s.strip.downcase
    return false if target.empty?

    won_sessions.any? do |session|
      entries = session.races.map { |race| race.get_racer_entry_by_name(user.username) }.compact
      entries.any? && entries.all? { |entry| entry.car_name.to_s.strip.downcase == target }
    end
  end

  # Did the user ever win a race (position 1) at a track with the given name?
  def won_race_at_track?(track_name)
    target = track_name.to_s.strip.downcase
    return false if target.empty?

    sessions.any? do |session|
      session.races.any? do |race|
        next false unless race.track_name.to_s.strip.downcase == target

        entry = race.get_racer_entry_by_name(user.username)
        entry && entry.position.to_i == 1
      end
    end
  end

  # --- Ranking-based helpers ------------------------------------------------

  # Did the user finish 1st in any *concluded* ranking?
  def won_ranking?
    Ranking.where('racer_result_entries.username' => user.username).any? do |ranking|
      ranking_concluded?(ranking) && ranking_winner(ranking) == user.username
    end
  end

  private

  # The winner of a session is the racer with the highest official score.
  def session_winner(session)
    session.racer_result_entries.max_by { |entry| entry.official_score.to_f }&.username
  end

  def ranking_winner(ranking)
    ranking.racer_result_entries.max_by { |entry| entry.official_score.to_f }&.username
  end

  # A ranking is considered "concluded" (and therefore winnable) once it is no
  # longer being played: it reached the full session count, its season is over,
  # or a later ranking exists in the same season.
  def ranking_concluded?(ranking)
    return true if ranking.sessions.size >= 28

    season = ranking.season
    return false if season.nil?
    return true unless season.current

    season.rankings.any? { |other| other.number.to_i > ranking.number.to_i }
  end
end

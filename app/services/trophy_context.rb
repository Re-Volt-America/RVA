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

  # --- Race-entry helpers ---------------------------------------------------

  # Distinct cars this user has driven across all of their races.
  def distinct_cars_driven_count
    my_race_entries.map { |(_s, _r, e)| e.car_name.to_s.strip.downcase }
                   .reject(&:empty?).uniq.size
  end

  # Distinct cars this user has won a race (position 1) with.
  def distinct_cars_won_with_count
    race_wins.map { |(_s, _r, e)| e.car_name.to_s.strip.downcase }
             .reject(&:empty?).uniq.size
  end

  # Distinct tracks this user has raced on.
  def distinct_tracks_count
    my_race_entries.map { |(_s, r, _e)| r.track_name.to_s.strip.downcase }
                   .reject(&:empty?).uniq.size
  end

  # Distinct tracks this user has won a race on.
  def distinct_tracks_won_count
    race_wins.map { |(_s, r, _e)| r.track_name.to_s.strip.downcase }
             .reject(&:empty?).uniq.size
  end

  # Won a race (position 1) that started with at least `min_starters` racers.
  def won_big_field_race?(min_starters)
    race_wins.any? { |(_s, r, _e)| r.total_racers.to_i >= min_starters }
  end

  # Finished a race that was at least `min_laps` laps long.
  def finished_long_race?(min_laps)
    my_race_entries.any? { |(_s, r, e)| e.finished && r.laps.to_i >= min_laps }
  end

  # Finished dead last (and actually finished) in a race with 3+ classified racers.
  def finished_last_in_a_race?
    my_race_entries.any? do |(_s, r, e)|
      max_pos = r.racer_entries.map { |x| x.position.to_i }.max.to_i
      max_pos >= 3 && e.finished && e.position.to_i == max_pos
    end
  end

  # Won every race they took part in, in a session with at least `min_races` races (default 20).
  def perfect_session?(min_races = 20)
    sessions.any? do |session|
      entries = session.races.map { |race| race.get_racer_entry_by_name(user.username) }.compact
      entries.size >= min_races && entries.all? { |e| e.position.to_i == 1 }
    end
  end

  # Longest run of consecutive session wins (ordered chronologically).
  def max_consecutive_session_wins
    best = current = 0
    sessions.sort_by { |s| [s.date || Date.new(0), s.number.to_i] }.each do |session|
      if session_winner(session) == user.username
        current += 1
        best = current if current > best
      else
        current = 0
      end
    end
    best
  end

  # Number of sessions this user finished 2nd in (by official score).
  def runner_up_count
    sessions.count do |session|
      ranked = session.racer_result_entries.sort_by { |e| -e.official_score.to_f }
      ranked[1]&.username == user.username
    end
  end

  # Season ids this user has competed in (memoised).
  def participated_season_ids
    @participated_season_ids ||= sessions.map { |session| session.ranking&.season_id }.compact.uniq
  end

  # Number of distinct seasons this user has competed in.
  def seasons_participated_count
    participated_season_ids.size
  end

  # Has the user competed in the given season (a Season or its id)?
  def participated_in_season?(season)
    sid = season.respond_to?(:id) ? season.id : season
    participated_season_ids.include?(sid)
  end

  # --- Head-to-head & leaderboard helpers -----------------------------------

  # Did the user finish ahead of `target_username` (higher official score) in a
  # session they both took part in? Usernames are stored upper-case.
  def beat_user_in_session?(target_username)
    target = target_username.to_s.strip.upcase
    return false if target.empty? || target == user.username

    sessions.any? do |session|
      mine = session.racer_result_entries.find { |e| e.username == user.username }
      theirs = session.racer_result_entries.find { |e| e.username == target }
      mine && theirs && mine.official_score.to_f > theirs.official_score.to_f
    end
  end

  # Did the user beat any of the site's current top `top_n` players (by obtained
  # points) in a session they both took part in?
  def beat_top_points_player?(top_n = 5)
    leaders = top_points_usernames(top_n) - [user.username]
    return false if leaders.empty?

    sessions.any? do |session|
      mine = session.racer_result_entries.find { |e| e.username == user.username }
      next false if mine.nil?

      leaders.any? do |leader|
        theirs = session.racer_result_entries.find { |e| e.username == leader }
        theirs && mine.official_score.to_f > theirs.official_score.to_f
      end
    end
  end

  # Has the user taken part in every season that exists?
  def participated_in_all_seasons?
    total = Season.count
    total.positive? && seasons_participated_count >= total
  end

  # Distinct cars the user has driven across the sessions they won.
  def distinct_cars_in_won_sessions_count
    won_sessions.flat_map { |session|
      session.races.map { |race| race.get_racer_entry_by_name(user.username)&.car_name }
    }.compact.map { |name| name.to_s.strip.downcase }.reject(&:empty?).uniq.size
  end

  # Did the user ever win a race (position 1) driving a car with the given name?
  def won_race_with_car?(car_name)
    target = car_name.to_s.strip.downcase
    return false if target.empty?

    race_wins.any? { |(_s, _r, e)| e.car_name.to_s.strip.downcase == target }
  end

  # Did the user beat a top `top_n` player (by obtained points) in a race while
  # that player was driving a car of equal or lower multiplier than the user's?
  # Only races where both cars are known (by multiplier) can qualify.
  def beat_top_player_with_lesser_car?(top_n = 5)
    leaders = top_points_usernames(top_n) - [user.username]
    return false if leaders.empty?

    my_race_entries.any? do |(_session, race, mine)|
      my_mult = car_multiplier(mine)
      next false if my_mult.nil?

      race.racer_entries.any? do |other|
        next false unless leaders.include?(other.username)
        next false unless other.position.to_i > mine.position.to_i # user finished ahead

        their_mult = car_multiplier(other)
        their_mult && their_mult <= my_mult
      end
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

  # [[session, race, entry], ...] for every race this user has an entry in.
  def my_race_entries
    @my_race_entries ||= sessions.flat_map do |session|
      session.races.filter_map do |race|
        entry = race.get_racer_entry_by_name(user.username)
        [session, race, entry] if entry
      end
    end
  end

  # The subset of my_race_entries the user won (finished 1st).
  def race_wins
    @race_wins ||= my_race_entries.select { |(_s, _r, e)| e.position.to_i == 1 }
  end


  # Usernames of the site's top `top_n` players by obtained points.
  def top_points_usernames(top_n)
    User.all
        .sort_by { |u| u.stats&.obtained_points.to_i }
        .reverse
        .first(top_n)
        .map(&:username)
  end


  # Multiplier of the car an entry drove, or nil when the car isn't referenced.
  def car_multiplier(entry)
    entry.car&.multiplier
  end

end

# frozen_string_literal: true

require 'set'

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

  # Process-wide caches for the expensive, user-INDEPENDENT lookups: the obtained-
  # points leaderboard and every car's multiplier. Without these a full recompute
  # is O(users^2) on the leaderboard and runs a Car query per race entry. The
  # cache has a short TTL so the live app never serves very stale data; the
  # recompute rake task resets it once up front so the whole run shares one
  # snapshot (points/cars don't change while awarding trophies anyway).
  SHARED_CACHE_TTL = 300 # seconds

  class << self
    def reset_shared_caches!
      @shared_cache = nil
    end

    def shared_cache
      @shared_cache = nil if @shared_cache && (Time.now - @shared_cache[:built_at]) > SHARED_CACHE_TTL
      @shared_cache ||= { :built_at => Time.now, :top_points => {} }
    end
  end

  def initialize(user, sessions: nil)
    @user = user
    # The bulk recompute injects this user's sessions so we never query per user.
    @sessions = sessions
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
    @sessions ||= Session
                  .where('racer_result_entries.username' => user.username)
                  .without(:session_log_data, :results_data)
                  .to_a
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
      entries.any? && entries.all? { |entry| entry_car_name(entry).to_s.strip.downcase == target }
    end
  end

  # Did the user ever win a race (position 1) at a track with the given name?
  def won_race_at_track?(track_name)
    target = track_name.to_s.strip.downcase
    return false if target.empty?

    sessions.any? do |session|
      session.races.any? do |race|
        next false unless race_track_name(race).to_s.strip.downcase == target

        entry = race.get_racer_entry_by_name(user.username)
        entry && entry.position.to_i == 1
      end
    end
  end

  # --- Ranking-based helpers ------------------------------------------------

  # Did the user finish 1st in any *concluded* ranking?
  def won_ranking?
    ranking_data[:winners].include?(user.username)
  end

  # --- Race-entry helpers ---------------------------------------------------

  # Distinct cars this user has driven across all of their races.
  def distinct_cars_driven_count
    my_race_entries.map { |(_s, _r, e)| entry_car_name(e).to_s.strip.downcase }
                   .reject(&:empty?).uniq.size
  end

  # Distinct cars this user has won a race (position 1) with.
  def distinct_cars_won_with_count
    race_wins.map { |(_s, _r, e)| entry_car_name(e).to_s.strip.downcase }
             .reject(&:empty?).uniq.size
  end

  # Distinct tracks this user has raced on.
  def distinct_tracks_count
    my_race_entries.map { |(_s, r, _e)| race_track_name(r).to_s.strip.downcase }
                   .reject(&:empty?).uniq.size
  end

  # Distinct tracks this user has won a race on.
  def distinct_tracks_won_count
    race_wins.map { |(_s, r, _e)| race_track_name(r).to_s.strip.downcase }
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
    @participated_season_ids ||= sessions.map(&:ranking_id).compact.uniq
                                         .map { |rid| ranking_data[:ranking_season][rid] }
                                         .compact.uniq
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
    total = (self.class.shared_cache[:season_count] ||= Season.count)
    total.positive? && seasons_participated_count >= total
  end

  # Distinct cars the user has driven across the sessions they won.
  def distinct_cars_in_won_sessions_count
    won_sessions.flat_map { |session|
      session.races.map { |race| entry_car_name(race.get_racer_entry_by_name(user.username)) }
    }.compact.map { |name| name.to_s.strip.downcase }.reject(&:empty?).uniq.size
  end

  # Did the user ever win a race (position 1) driving a car with the given name?
  def won_race_with_car?(car_name)
    target = car_name.to_s.strip.downcase
    return false if target.empty?

    race_wins.any? { |(_s, _r, e)| entry_car_name(e).to_s.strip.downcase == target }
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

  # Cached once for the whole run: a {ranking_id => season_id} map, and the set of
  # usernames who have won a *concluded* ranking. Built from a single aggregation
  # plus one pass over rankings/seasons, so evaluating won_ranking? and season
  # participation never issues a per-user ranking query.
  def ranking_data
    self.class.shared_cache[:ranking_data] ||= build_ranking_data
  end

  def build_ranking_data
    session_counts = Hash.new(0)
    Session.collection.aggregate(
      [{ '$group' => { '_id' => '$ranking_id', 'count' => { '$sum' => 1 } } }]
    ).each { |row| session_counts[row['_id']] = row['count'] }

    season_current = Season.all.only(:current).each_with_object({}) { |se, h| h[se.id] = se.current }

    rankings = Ranking.all.to_a
    max_number_by_season = Hash.new(0)
    rankings.each do |r|
      n = r.number.to_i
      max_number_by_season[r.season_id] = n if n > max_number_by_season[r.season_id]
    end

    ranking_season = {}
    winners = Set.new
    rankings.each do |ranking|
      ranking_season[ranking.id] = ranking.season_id

      concluded =
        session_counts[ranking.id] >= 28 ||
        (ranking.season_id && season_current[ranking.season_id] == false) ||
        (ranking.season_id && max_number_by_season[ranking.season_id] > ranking.number.to_i)
      next unless concluded

      top = ranking.racer_result_entries.max_by { |entry| entry.official_score.to_f }
      winners << top.username if top
    end

    { :ranking_season => ranking_season, :winners => winners }
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
    self.class.shared_cache[:top_points][top_n] ||=
      User.all
          .only(:username, :stats)
          .sort_by { |u| u.stats&.obtained_points.to_i }
          .reverse
          .first(top_n)
          .map(&:username)
  end


  # Multiplier of the car an entry drove, or nil when the car isn't referenced.
  # Uses a cached {car_id => multiplier} map to avoid a Car query per entry.
  def car_multiplier(entry)
    cid = entry.car_id
    cid && car_multipliers[cid]
  end

  def car_multipliers
    self.class.shared_cache[:car_multipliers] ||=
      Car.all.only(:multiplier).each_with_object({}) { |car, map| map[car.id] = car.multiplier }
  end


  # Car/Track NAMES by id, cached once. RacerEntry#car_name and Race#track_name
  # lazily load the associated Car/Track from the DB (a query per entry), which
  # is the real cost on a full recompute; these maps replace that with a lookup.
  def car_names
    self.class.shared_cache[:car_names] ||=
      Car.all.only(:name).each_with_object({}) { |car, map| map[car.id] = car.name }
  end

  def track_names
    self.class.shared_cache[:track_names] ||=
      Track.all.only(:name).each_with_object({}) { |track, map| map[track.id] = track.name }
  end

  # Name of the car an entry drove, without loading the Car document.
  def entry_car_name(entry)
    return nil if entry.nil?

    (entry.car_id && car_names[entry.car_id]) || entry.legacy_car_name
  end

  # Name of the track a race ran on, without loading the Track document.
  def race_track_name(race)
    return nil if race.nil?
    return race.legacy_track_name if race.legacy_track_name.present?

    race.track_id && track_names[race.track_id]
  end

end

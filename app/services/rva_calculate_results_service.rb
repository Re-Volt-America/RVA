#
# This service calculates a 2D array which represents the parsed results in Re-Volt America's format. This array
# contains things like the tracks played in the session, player names, positions, scoring, cars used, and other relevant
# data.
#
# This array is later used by the session's _show view to easily render the data in an ordered manner.
#
# @return The RVA results array.
class RvaCalculateResultsService
  include ApplicationHelper

  # Represents a player's entry in the final RVA results table.
  class RacerResultEntry
    attr_reader :username, :race_count, :average_position, :obtained_points, :official_score, :played_tracks,
                :participation_multiplier, :team

    def initialize(username, race_count, average_position, obtained_points, official_score, played_tracks,
                   participation_multiplier, team)
      @username = username
      @race_count = race_count
      @average_position = average_position
      @obtained_points = obtained_points
      @official_score = official_score
      @played_tracks = played_tracks
      @participation_multiplier = participation_multiplier
      @team = team
    end
  end

  def initialize(session)
    @session = session
    @races = session.races
  end

  def call
    get_rva_singles_results_arr
  end

  def get_rva_singles_results_arr
    rva_results_arr = [['#', 'Date'] + get_tracks_arr + %w(PP PA CC MP PO)]

    first = true
    pos = 1
    racer_result_entries = get_racer_result_entries_arr
    racer_result_entries.each do |result_entry|
      name = result_entry.username
      user = find_user(result_entry.username)

      if first
        racer_positions_line_arr = [@session.number, @session.date]
        first = false
      else
        racer_positions_line_arr = ['', '']
      end

      racer_positions_line_arr += [pos.to_s, user]
      racer_positions_line_arr << get_racer_positions_arr(name)
      racer_positions_line_arr << result_entry.average_position
      racer_positions_line_arr << result_entry.obtained_points
      racer_positions_line_arr << result_entry.race_count
      racer_positions_line_arr << result_entry.participation_multiplier
      racer_positions_line_arr << result_entry.official_score

      racer_cars_line_arr = ['', '', '', '']
      racer_cars_line_arr << get_racer_cars_arr(name)

      rva_results_arr << racer_positions_line_arr
      rva_results_arr << racer_cars_line_arr

      pos += 1
    end

    rva_results_arr
  end

  def get_tracks_arr
    tracks = []

    @races.each do |race|
      tracks << find_track(race.track_id)
    end

    tracks
  end

  def get_racer_positions_arr(racer)
    racer_positions_arr = []

    @races.each do |race|
      unless race.get_racer_names.include?(racer)
        racer_positions_arr << ''
        next
      end

      racer_entry = race.get_racer_entry_by_name(racer)
      car_bonus = get_car_bonus(find_car(racer_entry.car_id))

      # Car was invalid for whatever reason, so we prepend "'" to the position
      racer_positions_arr << "'#{racer_entry.position}" if car_bonus.nil?

      racer_positions_arr << "#{racer_entry.position}"
    end

    racer_positions_arr
  end

  def get_racer_cars_arr(racer)
    cars_line_arr = []
    last_car_used_id = nil

    @races.each do |race|
      # The category is Random, therefore we ignore cars for results
      if @session.category == SYS::CATEGORY::RANDOM
        cars_line_arr << ''
        next
      end

      # Player didn't play this race, so we skip
      unless race.get_racer_names.include?(racer)
        cars_line_arr << 'x'
        next
      end

      car_used_id = race.get_racer_entry_by_name(racer).car_id

      # Player hasn't changed cars, so we skip
      if car_used_id.eql?(last_car_used_id)
        cars_line_arr << ''
        next
      end

      car = find_car(car_used_id)

      # If the car is a clockwork, trim 'Clockwork' from its name and leave the rest,
      # except if it's just 'Clockwork'. This only has aesthetic purposes.
      if !car.name.eql?(SYS::CAR::CLOCKWORK_NAME) and car.name.start_with?(SYS::CAR::CLOCKWORK_NAME)
        car.name = car.name.split(' ', 1)[1]
      end

      cars_line_arr << car

      last_car_used_id = car_used_id
    end

    cars_line_arr << '!'
    cars_line_arr << '!'
    cars_line_arr << '!'
    cars_line_arr << '!'
    cars_line_arr << '!'
    cars_line_arr
  end

  def get_racer_result_entries_arr
    racer_result_entries_arr = []

    get_racers_arr.each do |racer|
      average_position = get_average_position(racer)
      obtained_points = get_obtained_points(racer)
      participation_multiplier = get_participation_multiplier(racer)
      official_score = get_official_score(obtained_points, average_position, participation_multiplier)
      race_count = get_race_count(racer)
      played_tracks = get_tracks_played(racer)
      team = get_team(racer)

      racer_result_entries_arr << RacerResultEntry.new(racer,
                                                       race_count,
                                                       average_position,
                                                       obtained_points,
                                                       official_score,
                                                       played_tracks,
                                                       participation_multiplier,
                                                       team)
    end

    if @session.teams
      racer_result_entries_arr.sort_by { |e| e.obtained_points }.reverse!
    else
      racer_result_entries_arr.sort_by { |e| e.official_score }.reverse!
    end
  end

  def get_racers_arr
    racers = []

    @races.each do |race|
      race.racer_entries.each do |entry|
        next if racers.include? entry.username

        racers << entry.username
      end
    end

    racers
  end

  def get_average_position(racer)
    race_count = get_race_count(racer)
    return 0 if race_count.zero?

    racer_entries = @session.get_racer_entries_arr_for_name(racer)

    positions_sum = 0.0
    racer_entries.each do |entry|
      positions_sum += entry.position
    end

    (positions_sum / @races.size).round(2)
  end

  def get_obtained_points(racer)
    obtained_points = 0

    @races.each do |race|
      race.racer_entries.each do |entry|
        obtained_points += get_racer_score(race, entry) if entry.username.eql?(racer)
      end
    end

    obtained_points.round(0)
  end

  def get_racer_score(race, entry)
    car = find_car(entry.car_id)
    car_bonus = get_car_bonus(car)

    # Car is above the current category's class or invalid, therefore points are invalidated
    return 0.0 if car_bonus.nil?

    final_multiplier = (car.multiplier * car_bonus).round(3)
    final_multiplier = 4.0 if final_multiplier > 4.0

    big_race = race.racers_count >= 10

    # Racer score
    (get_position_score(entry.position, big_scoring = big_race) * final_multiplier).round(3)
  end

  def get_position_score(position, big_scoring)
    return SYS::SCORING::BIG[position] if big_scoring

    SYS::SCORING::NORMAL[position]
  end

  def get_car_bonus(car)
    return nil if car.name == SYS::CAR::MYSTERY_NAME

    return 1.0 if @session.category == SYS::CATEGORY::RANDOM

    if @session.category == SYS::CATEGORY::CLOCKWORK and car.category == SYS::CATEGORY::CLOCKWORK
      return 1.0  # The current category is Clockwork, and player is using a Clockwork, therefore valid and 1.0
    elsif @session.category == SYS::CATEGORY::CLOCKWORK and car.category != SYS::CATEGORY::CLOCKWORK
      return nil  # The current category is Clockwork, but the player is not using a Clockwork, therefore invalid
    elsif @session.category != SYS::CATEGORY::CLOCKWORK and car.category == SYS::CATEGORY::CLOCKWORK
      return nil  # The current category is not Clockwork, but player is using a Clockwork, therefore invalid
    end

    # RANDOM and CLOCKWORK never make it here, so no side effects!
    car_category_delta = @session.category - car.category
    if car_category_delta < 0
      return nil # Car is above the current category, therefore points are invalid
    end

    SYS::CATEGORY::BONUSES_PER_DIFF[car_category_delta]
  end

  def get_participation_multiplier(racer)
    (Float(get_race_count(racer)) / @session.races.size).round(2)
  end

  def get_official_score(obtained_points, average_position, participation_multiplier)
    official_score = obtained_points / average_position
    official_score *= participation_multiplier
    official_score *= SYS::SCORING::NORMALIZER_CONSTANT

    official_score.round(2)
  end

  def get_race_count(racer)
    get_tracks_played(racer).size
  end

  # NOTE: Returns track IDs
  def get_tracks_played(racer)
    played_tracks = []

    @races.each do |race|
      played_tracks << race.track_id if race.get_racer_names.include?(racer)
    end

    played_tracks
  end

  # FIXME: Link to team models
  def get_team(racer)
    false
  end

  def find_user(name)
    Rails.cache.fetch("User##{name}") do
      User.find { |u| u.username.eql?(name) }
    end
  end

  def find_track(track_id)
    Rails.cache.fetch("Track##{track_id}") do
      Track.find { |t| t.id.eql?(track_id) }
    end
  end

  def find_car(car_id)
    Rails.cache.fetch("Car##{car_id}") do
      Car.find { |c| c.id.eql?(car_id) }
    end
  end
end

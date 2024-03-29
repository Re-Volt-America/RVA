#
# This service is used to generate a 2D array of race results in Re-Volt America's format. This array
# contains things like the tracks played in the session, player names, positions, scoring, cars used, and other relevant
# data.
#
# The generated array is later used by the session views to easily render the data as an actual table.
#
class RvaCalculateResultsService
  include ApplicationHelper

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
    if @session.teams
      get_rva_teams_results_arr
    else
      get_rva_singles_results_arr
    end
  end

  def get_rva_singles_results_arr
    rva_results_arr = [%w(# Date) + get_tracks_arr + %w(PP PA CC MP PO)]

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

      racer_positions_line_arr += [pos.to_s, user.nil? ? result_entry.username : user]
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

  def get_rva_teams_results_arr
    rva_teams_results_arr = [%w(# Date) + get_tracks_arr + %w(CC PA)]

    first = true
    pos = 1
    racer_result_entries = get_racer_result_entries_arr
    racer_result_entries.each do |result_entry|
      full_username = result_entry.username

      username = full_username.partition(' ').last
      team_name = full_username.partition(' ').first

      user = find_user(username)
      team = find_team(team_name)

      if first
        racer_positions_line_arr = [@session.number, @session.date]
        first = false
      else
        racer_positions_line_arr = ['', '']
      end

      racer_positions_line_arr += [pos.to_s, (user.nil? ? username : user), (team.nil? ? team_name : team)]
      racer_positions_line_arr << get_racer_positions_arr(full_username)
      racer_positions_line_arr << result_entry.race_count
      racer_positions_line_arr << result_entry.obtained_points
      racer_cars_line_arr = ['', '', '', '', '']
      racer_cars_line_arr << get_racer_cars_arr(full_username)

      rva_teams_results_arr << racer_positions_line_arr
      rva_teams_results_arr << racer_cars_line_arr

      pos += 1
    end

    rva_teams_results_arr
  end

  def get_tracks_arr
    tracks = []

    @races.each do |race|
      tracks << find_track(race.track_name)
    end

    tracks
  end

  def get_racer_positions_arr(racer)
    racer_positions_arr = []

    @races.each do |race|
      # Racer didn't play this race
      unless race.get_racer_names.include?(racer)
        racer_positions_arr << ''
        next
      end

      racer_entry = race.get_racer_entry_by_name(racer)
      car_bonus = get_car_bonus(find_car(racer_entry.car_name))

      # Car was invalid for whatever reason, so we prepend "'" to the position
      if car_bonus.nil?
        racer_positions_arr << "'#{racer_entry.position}"
        next
      end

      racer_positions_arr << racer_entry.position.to_s
    end

    racer_positions_arr
  end

  def get_racer_cars_arr(racer)
    cars_line_arr = []
    last_car_used_name = nil

    @races.each do |race|
      # The category is Random, therefore we ignore cars for results
      if @session.category == SYS::CATEGORY::RANDOM
        cars_line_arr << 'r'
        next
      end

      # Player didn't play this race, so we skip
      unless race.get_racer_names.include?(racer)
        cars_line_arr << 'x'
        next
      end

      car_used_name = race.get_racer_entry_by_name(racer).car_name

      # Player hasn't changed cars, so we skip
      if car_used_name.eql?(last_car_used_name)
        cars_line_arr << ''
        next
      end

      # Player hasn't changed cars, so we skip (unlinked cars)
      if "?#{car_used_name}".eql?(last_car_used_name)
        cars_line_arr << '??'
        next
      end

      car = find_car(car_used_name)

      # The car used by this player doesn't match the following criteria:
      # - It's not part of this session's season
      # - It's not found in our database (no car with its name exists)
      if car.nil?
        cars_line_arr << "?#{car_used_name}"
        last_car_used_name = "?#{car_used_name}"
        next
      end

      # If the car is a clockwork, trim 'Clockwork' from its name and leave the rest,
      # except if it's just 'Clockwork'. This only has aesthetic purposes.
      if !car.name.eql?(SYS::CAR::CLOCKWORK_NAME) && car.name.start_with?(SYS::CAR::CLOCKWORK_NAME)
        car.name = car.name.split(' ', 1)[1]
      end

      cars_line_arr << car
      last_car_used_name = car_used_name
    end

    if @session.teams
      cars_line_arr << '!CC'
      cars_line_arr << '!PA'
    else
      cars_line_arr << '!PP'
      cars_line_arr << '!PA'
      cars_line_arr << '!CC'
      cars_line_arr << '!MP'
      cars_line_arr << '!PO'
    end

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
      racer_result_entries_arr.sort_by(&:obtained_points).reverse!
    else
      racer_result_entries_arr.sort_by(&:official_score).reverse!
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

    racer_entries = @session.get_racer_entries_arr(racer)

    positions_sum = 0.0
    racer_entries.each do |entry|
      positions_sum += entry.position
    end

    (positions_sum / race_count).round(2)
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
    car = find_car(entry.car_name)
    car_bonus = get_car_bonus(car)

    # Car is above the current category or is invalid, therefore points are invalidated
    return 0.0 if car_bonus.nil?

    final_multiplier = (car.multiplier * car_bonus).round(3)
    final_multiplier = 4.0 if final_multiplier > 4.0

    big_race = race.finished_racers_count >= 10

    racer_score = get_position_score(entry.position, big_race) * final_multiplier
    racer_score.round(3)
  end

  def get_position_score(position, big_scoring)
    return SYS::SCORING::BIG[position] if big_scoring

    SYS::SCORING::NORMAL[position]
  end

  def get_car_bonus(car)
    return nil if car.nil?
    return nil if car.name == SYS::CAR::MYSTERY_NAME

    return 1.0 if @session.category == SYS::CATEGORY::RANDOM

    if (@session.category == SYS::CATEGORY::CLOCKWORK) && (car.category == SYS::CATEGORY::CLOCKWORK)
      return 1.0  # The current category is Clockwork, and player is using a Clockwork, therefore valid and 1.0
    elsif (@session.category == SYS::CATEGORY::CLOCKWORK) && (car.category != SYS::CATEGORY::CLOCKWORK)
      return nil  # The current category is Clockwork, but the player is not using a Clockwork, therefore invalid
    elsif (@session.category != SYS::CATEGORY::CLOCKWORK) && (car.category == SYS::CATEGORY::CLOCKWORK)
      return nil  # The current category is not Clockwork, but player is using a Clockwork, therefore invalid
    end

    # RANDOM and CLOCKWORK never make it here, so no side effects!
    car_category_delta = @session.category - car.category
    if car_category_delta.negative?
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

  def get_tracks_played(racer)
    played_tracks = []

    @races.each do |race|
      played_tracks << race.track_name if race.get_racer_names.include?(racer)
    end

    played_tracks
  end

  # FIXME: Link to team models
  def get_team(_racer)
    false
  end

  def find_user(name)
    Rails.cache.fetch("Session:#{@session.id}#User:#{name.upcase}", :expires_in => 1.minute) do
      User.find { |u| u.username.eql?(name.upcase) }
    end
  end

  def find_track(track_name)
    Rails.cache.fetch("Session:#{@session.id}#Track:#{track_name}", :expires_in => 1.minute) do
      Track.find { |t| t.name_variations.include?(track_name) && t.season.eql?(@session.season) }
    end
  end

  def find_car(car_name)
    Rails.cache.fetch("Session:#{@session.id}#Car:#{car_name}", :expires_in => 1.minute) do
      Car.find { |c| c.name.eql?(car_name) && c.season.eql?(@session.season) }
    end
  end

  def find_team(short_name)
    Rails.cache.fetch("Session:#{@session.id}#Team:#{short_name}", :expires_in => 1.minute) do
      Team.find { |t| t.short_name.eql?(short_name) }
    end
  end
end

class CalculateRvaResultsService
  include ApplicationHelper

  # FIXME: Replace :name by User model?
  # FIXME: Replace :team by Team model?

  # Represents a player's entry in the final RVA results table.
  class RacerResultEntry
    attr_reader :name, :race_count, :average_position, :obtained_points, :official_score, :played_tracks, :participation_multiplier, :team

    def initialize(name, race_count, average_position, obtained_points, official_score, played_tracks, participation_multiplier, team)
      @name = name
      @race_count = race_count
      @average_position = average_position
      @obtained_points = obtained_points
      @official_score = official_score
      @played_tracks = played_tracks
      @participation_multiplier = participation_multiplier
      @team = team
    end
  end

  # FIXME: This might be a task for redis...
  class Storage
    attr_reader :track_storage, :car_storage

    def initialize
      @track_storage = []
      @car_storage = []
    end
  end

  def initialize(session)
    @session = session
    @races = session.races
    @storage = Storage.new
  end

  def call
    get_rva_singles_results_arr
  end

  # This method returns a 2D array which represents the parsed results in Re-Volt America's format. This array contains
  # things like the tracks played in the session, player names, positions, scoring, cars used, and other relevant data.
  #
  # This array is later used by the session's _show view to easily render the data in an ordered manner.
  #
  # @return The RVA results array.
  def get_rva_singles_results_arr
    rva_results_arr = [["Pos", "Racer"] + self.get_tracks_arr + ["PP", "PA", "CC", "MP", "PO"]]

    pos = 1
    racer_result_entries = self.get_racer_result_entries_arr
    racer_result_entries.each do |result_entry|
      name = result_entry.name
      racer_positions_line_arr = [pos.to_s, name] + self.get_racer_positions_arr(name)
      racer_positions_line_arr << result_entry.average_position
      racer_positions_line_arr << result_entry.obtained_points
      racer_positions_line_arr << result_entry.race_count
      racer_positions_line_arr << result_entry.participation_multiplier
      racer_positions_line_arr << result_entry.official_score

      racer_cars_line_arr = ["", ""] + self.get_racer_cars_arr(name)

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
        racer_positions_arr << ""
        next
      end

      racer_entry = race.racer_entries.find { |entry| entry.name.eql?(racer) }
      car_bonus = get_car_bonus(find_car(racer_entry.car_id))

      # Car was invalid for whatever reason, so we prepend "'" to the position
      if car_bonus.nil?
        racer_positions_arr << "'#{racer_entry.position}"
      end

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
        cars_line_arr << ""
        next
      end

      # Player didn't play this race, so we skip
      unless race.get_racer_names.include?(racer)
        cars_line_arr << ""
        next
      end

      car_used_id = race.get_racer_entry_by_name(racer).car_id

      # Player hasn't changed cars, so we skip
      if car_used_id.eql?(last_car_used_id)
        cars_line_arr << ""
        next
      end

      car = find_car(car_used_id)

      # If the car is a clockwork, trim 'Clockwork' from its name and leave the rest,
      # except if it's just 'Clockwork'. This only has aesthetic purposes.
      if not car.name.eql?(SYS::CAR::CLOCKWORK_NAME) and car.name.start_with?(SYS::CAR::CLOCKWORK_NAME)
        cars_line_arr << (car.name.split(" ", 1)[1])
      else
        cars_line_arr << car.name
      end

      last_car_used_id = car_used_id
    end

    cars_line_arr << " "
    cars_line_arr
  end

  def get_racer_result_entries_arr
    racer_result_entries = []

    self.get_racers.each do |racer|
      average_position = self.get_average_position(racer)
      obtained_points = self.get_obtained_points(racer)
      participation_multiplier = self.get_participation_multiplier(racer)
      official_score = self.get_official_score(obtained_points, average_position, participation_multiplier)
      race_count = self.get_race_count(racer)
      played_tracks = self.get_tracks_played(racer)
      team = self.get_team(racer)

      racer_result_entries << RacerResultEntry.new(racer, race_count, average_position, obtained_points, official_score, played_tracks, participation_multiplier, team)
    end

    if @session.teams
      racer_result_entries.sort_by { |e| e.obtained_points }
    else
      racer_result_entries.sort_by { |e| e.official_score }
    end

    racer_result_entries
  end

  # FIXME: Link to user models
  def get_racers
    racers = []

    @races.each do |race|
      race.racer_entries.each do |entry|
        next if racers.include? entry.name

        racers << entry.name
      end
    end

    racers
  end

  def get_racer_entries(racer)
    racer_entries = []

    @races.each do |race|
      race.racer_entries.each do |entry|
        if entry.name.eql?(racer)
          racer_entries << entry
        end
      end
    end

    racer_entries
  end

  def get_average_position(racer)
    race_count = self.get_race_count(racer)
    return 0 if race_count.zero?

    racer_entries = self.get_racer_entries(racer)

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
        if entry.name.eql?(racer)
          obtained_points = obtained_points + get_racer_score(entry, race)
        end
      end
    end

    obtained_points.round(0)
  end

  def get_racer_score(entry, race)
    car = find_car(entry.car_id)
    car_bonus = self.get_car_bonus(car)

    # Car is above the current category's class or invalid, therefore points are invalidated
    if car_bonus.nil?
      return 0.0
    end

    final_multiplier = (car.multiplier * car_bonus).round(3)
    if final_multiplier > 4.0
      final_multiplier = 4.0
    end

    big_race = race.racers_count >= 10

    # Racer score
    (self.get_position_score(entry.position, big_scoring=big_race) * final_multiplier).round(3)
  end

  def get_position_score(position, big_scoring)
    if big_scoring
      return SYS::SCORING::BIG[position] # FIXME: Check if this is mapping to the right number
    end

    SYS::SCORING::NORMAL[position]
  end

  def get_car_bonus(car)
    if car.name == SYS::CAR::MYSTERY_NAME
      return nil
    end

    if @session.category == SYS::CATEGORY::RANDOM
      return 1.0
    end

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
      return nil  # Car is above the current category, therefore points are invalid
    end

    SYS::CATEGORY::BONUSES_PER_DIFF[car_category_delta]
  end

  def get_participation_multiplier(racer)
    (Float(get_race_count(racer)) / @session.races.size).round(2)
  end

  def get_official_score(obtained_points, average_position, participation_multiplier)
    official_score = obtained_points / average_position
    official_score = official_score * participation_multiplier
    official_score = official_score * SYS::SCORING::NORMALIZER_CONSTANT

    official_score.round(2)
  end

  def get_race_count(racer)
    self.get_tracks_played(racer).size
  end

  # NOTE: Returns track IDs
  def get_tracks_played(racer)
    played_tracks = []

    @races.each do |race|
      if race.get_racer_names.include?(racer)
        played_tracks << race.track_id
      end
    end

    played_tracks
  end

  # FIXME: Link to team models
  def get_team(racer)
    false
  end

  def find_track(track_id)
    track = @storage.track_storage.find { |t| t.id.eql?(track_id) }

    if track.nil?
      track = Track.find { |t| t.id.eql?(track_id)}
      @storage.track_storage << track
    end

    track
  end

  def find_car(car_id)
    car = @storage.car_storage.find { |c| c.id.eql?(car_id)}

    if car.nil?
      car = Car.find { |c| c.id.eql?(car_id)}
      @storage.car_storage << car
    end

    car
  end
end

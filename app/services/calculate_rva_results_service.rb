class CalculateRvaResultsService
  include ApplicationHelper

  # Car classes (rva-specific & rvgl)
  RVA_CLASSES_NAMES = ["rookie", "amateur", "advanced", "semi-pro", "pro", "super-pro", "random", "clockwork"]
  RVGL_CAR_CLASSES_NAMES = ["rookie", "amateur", "advanced", "semi-pro", "pro", "super-pro", "clockwork"]

  # Internal car class values
  ROOKIE = 0
  AMATEUR = 1
  ADVANCED = 2
  SEMI_PRO = 3
  PRO = 4
  SUPER_PRO = 5
  RANDOM = 6
  CLOCKWORK = 7

  # Special car names
  MYSTERY_NAME = "Mystery"
  CLOCKWORK_NAME = "Clockwork"

  BONUSES_PER_CLASS_DIFF = {
      0 => 1.0,
      1 => 1.25,
      2 => 1.5,
      3 => 1.75,
      4 => 2,
      5 => 2.25
  }

  CLASS_NUMBERS_MAP = {
      :rookie => ROOKIE,
      :amateur => AMATEUR,
      :advanced => ADVANCED,
      :"semi-pro" => SEMI_PRO,
      :pro => PRO,
      :"super-pro" => SUPER_PRO,
      :random => RANDOM,
      :clockwork => CLOCKWORK
  }

  # TODO: Simplify
  POSITION_SUFFIXES = {
      1 => "st",
      2 => "nd",
      3 => "rd",
      4 => "th",
      5 => "th",
      6 => "th",
      7 => "th",
      8 => "th",
      9 => "th",
      10 => "th",
      11 => "th",
      12 => "th",
      13 => "th",
      14 => "th",
      15 => "th",
      16 => "th"
  }

  SCORING = {
      1 => 15,
      2 => 12,
      3 => 10,
      4 => 7,
      5 => 5,
      6 => 4,
      7 => 2, 8 => 2,
      9 => 1,
      10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1
  }

  BIG_SCORING = {
      1 => 20,
      2 => 16,
      3 => 12,
      4 => 10,
      5 => 8, 6 => 8,
      7 => 6,
      8 => 4,
      9 => 2, 10 => 2,
      11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1
  }

  NORMALIZER_CONSTANT = 0.1

  # FIXME: Replace name by user model?
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

  def initialize(session)
    @session = session
    @races = session.races
  end

  def call
    get_rva_singles_results_arr
  end

  # FIXME: Revise table headers (should be in english by default)
  def get_rva_singles_results_arr
    rva_results = [["Pos", "Racer"] + self.get_tracks_arr + ["PP", "PA", "CC", "MP", "PO"]]

    pos = 1
    racer_result_entries = self.get_racer_result_entries
  end

  def get_tracks_arr
    tracks = []

    # FIXME: check for repeated tracks to improve performance
    @races.each do |race|
      track_id = race.track_id
      tracks << Track.find { |t| t.id.eql?(track_id)}
    end

    tracks
  end

  def get_racer_result_entries
    racer_result_entries = []

    self.get_racers.each do |racer|
      avg_pos = self.get_average_position(racer)
      obtained_points = self.get_obtained_points(racer)
      participation_multiplier = self.get_participation_multiplier(racer)
      official_score = self.get_official_score(racer)
      race_count = self.get_race_count(racer)
      played_tracks = self.get_tracks_played(racer)
      team = self.get_team(racer)

      racer_result_entries << RacerResultEntry.new(racer, race_count, avg_pos, obtained_points, official_score, played_tracks, participation_multiplier, team)
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

      end
    end
  end

  def get_participation_multiplier(racer)
    0.0
  end

  def get_official_score(racer)
    0.0
  end

  # FIXME: this is very inefficient
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
end

class CalculateRvaResultsService
  include ApplicationHelper

  # FIXME: Replace name by user model?
  class RacerResultEntry
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

    byebug

    if @session.teams # FIXME: broken
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

  def get_average_position(racer)
    0.0
  end

  def get_obtained_points(racer)
    0.0
  end

  def get_participation_multiplier(racer)
    0.0
  end

  def get_official_score(racer)
    0.0
  end

  def get_race_count(racer)
    0.0
  end

  def get_tracks_played(racer)
    0.0
  end

  # FIXME: Link to team models
  def get_team(racer)
    false
  end
end

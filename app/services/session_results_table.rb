class SessionResultsTable
  class ResultRow
    attr_reader :final_position, :racer, :team, :positions, :cars,
                :average_position, :obtained_points, :race_count,
                :participation_multiplier, :official_score

    def initialize(final_position:, racer:, team:, positions:, cars:, average_position:, obtained_points:, race_count:,
                   participation_multiplier:, official_score:)
      @final_position = final_position
      @racer = racer
      @team = team
      @positions = positions
      @cars = cars
      @average_position = average_position
      @obtained_points = obtained_points
      @race_count = race_count
      @participation_multiplier = participation_multiplier
      @official_score = official_score
    end

    def racer_user
      racer.is_a?(User) ? racer : nil
    end

    def racer_name
      racer_user&.username || racer
    end

    def team_entity
      team.is_a?(Team) ? team : nil
    end

    def team_name
      team_entity&.short_name || team
    end

    def as_serialized
      {
        'final_position' => final_position,
        'racer_user_id' => racer_user&.id&.to_s,
        'racer_name' => racer_name,
        'team_id' => team_entity&.id&.to_s,
        'team_name' => team_name,
        'positions' => positions,
        'cars' => cars.map { |car| serialize_car_cell(car) },
        'average_position' => average_position,
        'obtained_points' => obtained_points,
        'race_count' => race_count,
        'participation_multiplier' => participation_multiplier,
        'official_score' => official_score
      }
    end

    def self.from_serialized(payload, users_by_id:, teams_by_id:, cars_by_id:)
      racer = payload['racer_user_id'] ? (users_by_id[payload['racer_user_id']] || payload['racer_name']) : payload['racer_name']
      team = payload['team_id'] ? (teams_by_id[payload['team_id']] || payload['team_name']) : payload['team_name']

      cars = payload.fetch('cars', []).map do |cell|
        next cell['value'] unless cell['type'] == 'car'

        cars_by_id[cell['car_id']] || cell['car_name']
      end

      new(
        :final_position => payload['final_position'],
        :racer => racer,
        :team => team,
        :positions => payload.fetch('positions', []),
        :cars => cars,
        :average_position => payload['average_position'],
        :obtained_points => payload['obtained_points'],
        :race_count => payload['race_count'],
        :participation_multiplier => payload['participation_multiplier'],
        :official_score => payload['official_score']
      )
    end

    private

    def serialize_car_cell(cell)
      return { 'type' => 'car', 'car_id' => cell.id.to_s, 'car_name' => cell.name } if cell.is_a?(Car)

      { 'type' => 'value', 'value' => cell }
    end
  end

  attr_reader :session_number, :session_date, :teams, :tracks, :rows

  def initialize(session_number:, session_date:, teams:, tracks:, rows:)
    @session_number = session_number
    @session_date = session_date
    @teams = teams
    @tracks = tracks
    @rows = rows
  end

  def as_serialized
    {
      'session_number' => session_number,
      'session_date' => session_date,
      'teams' => teams,
      'tracks' => tracks.map { |track| serialize_track(track) },
      'rows' => rows.map(&:as_serialized)
    }
  end

  def to_legacy_array
    metrics = teams ? %w(CC PA) : %w(PP PA CC MP PO)
    table = [%w(# Date) + tracks + metrics]

    rows.each_with_index do |row, idx|
      first = idx.zero?

      if teams
        positions_row = [
          (first ? session_number : ''),
          (first ? session_date : ''),
          row.final_position,
          row.racer,
          row.team,
          row.positions,
          row.race_count,
          row.obtained_points
        ]
        cars_row = ['', '', '', '', '', row.cars]
      else
        positions_row = [
          (first ? session_number : ''),
          (first ? session_date : ''),
          row.final_position,
          row.racer,
          row.positions,
          row.average_position,
          row.obtained_points,
          row.race_count,
          row.participation_multiplier,
          row.official_score
        ]
        cars_row = ['', '', '', '', row.cars]
      end

      table << positions_row
      table << cars_row
    end

    table
  end

  def self.from_legacy_array(rva_results, session)
    return new(:session_number => session.number, :session_date => session.date, :teams => session.teams, :tracks => [], :rows => []) if rva_results.blank?

    tracks = rva_results[0].slice(2, session.races.size)
    rows = []

    rva_results.drop(1).each_slice(2) do |positions_row, cars_row|
      next if positions_row.nil?

      if session.teams?
        rows << ResultRow.new(
          :final_position => positions_row[2],
          :racer => positions_row[3],
          :team => positions_row[4],
          :positions => positions_row[5] || [],
          :cars => (cars_row && cars_row[5]) || [],
          :average_position => nil,
          :obtained_points => positions_row[7],
          :race_count => positions_row[6],
          :participation_multiplier => nil,
          :official_score => nil
        )
      else
        rows << ResultRow.new(
          :final_position => positions_row[2],
          :racer => positions_row[3],
          :team => nil,
          :positions => positions_row[4] || [],
          :cars => (cars_row && cars_row[4]) || [],
          :average_position => positions_row[5],
          :obtained_points => positions_row[6],
          :race_count => positions_row[7],
          :participation_multiplier => positions_row[8],
          :official_score => positions_row[9]
        )
      end
    end

    new(
      :session_number => session.number,
      :session_date => session.date,
      :teams => session.teams,
      :tracks => tracks,
      :rows => rows
    )
  end

  def self.from_serialized(data, session:)
    return new(:session_number => session.number, :session_date => session.date, :teams => session.teams, :tracks => [], :rows => []) if data.blank?

    if data.is_a?(Array)
      return from_legacy_array(data, session)
    end

    track_ids = data.fetch('tracks', []).map { |t| t['track_id'] }.compact
    user_ids = data.fetch('rows', []).map { |r| r['racer_user_id'] }.compact
    team_ids = data.fetch('rows', []).map { |r| r['team_id'] }.compact
    car_ids = data.fetch('rows', []).flat_map { |r| r.fetch('cars', []).map { |c| c['car_id'] } }.compact

    tracks_by_id = Track.where(:id.in => track_ids).to_a.index_by { |t| t.id.to_s }
    users_by_id = User.where(:id.in => user_ids).to_a.index_by { |u| u.id.to_s }
    teams_by_id = Team.where(:id.in => team_ids).to_a.index_by { |t| t.id.to_s }
    cars_by_id = Car.where(:id.in => car_ids).to_a.index_by { |c| c.id.to_s }

    tracks = data.fetch('tracks', []).map do |payload|
      next nil if payload.nil?

      if payload['track_id']
        tracks_by_id[payload['track_id']] || payload['track_name']
      else
        payload['track_name']
      end
    end

    rows = data.fetch('rows', []).map do |payload|
      ResultRow.from_serialized(payload, :users_by_id => users_by_id, :teams_by_id => teams_by_id, :cars_by_id => cars_by_id)
    end

    new(
      :session_number => data['session_number'] || session.number,
      :session_date => data['session_date'] || session.date,
      :teams => data.key?('teams') ? data['teams'] : session.teams,
      :tracks => tracks,
      :rows => rows
    )
  end

  private

  def serialize_track(track)
    return { 'track_id' => track.id.to_s, 'track_name' => track.name } if track.is_a?(Track)

    { 'track_id' => nil, 'track_name' => track }
  end
end

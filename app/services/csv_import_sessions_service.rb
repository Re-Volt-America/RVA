class CsvImportSessionsService
  include ApplicationHelper

  require 'csv'
  require 'rva_calculate_results_service'
  require 'stats_service'
  require 'team_points_service'

  def initialize(file, ranking, category, number, teams)
    @file = file
    @ranking = ranking
    @category = category
    @number = number
    @teams = teams
  end

  def parse_and_format_date(date_string)
    formats = [
      '%D',                       # Expected format 'mm/dd/yy H:mm:ss' from Windows machines
      '%a %b %e %H:%M:%S %Y'      # Expected format 'ddd mmm d H:mm:ss yyyy' from Unix machines
    ]

    parsed_date = nil

    formats.each do |format|
      parsed_date = Date.strptime(date_string, format)
      break
    rescue ArgumentError
      next
    end

    raise ArgumentError, 'Unrecognised date format' if parsed_date.nil?

    parsed_date
  end

  def call
    csv = CSV.parse(File.open(@file))

    unless is_rv_session_log(csv)
      return nil # FIXME: handle?
    end

    session_arr = []
    csv.each do |row|
      session_arr << row
    end

    session_hash = {
      :number => Ranking.find { |r| r.id.to_s.eql?(@ranking) }.sessions.size + 1,
      :host => true?(@teams) ? session_arr[1][2].partition(' ').last : session_arr[1][2],
      :version => session_arr[0][1],
      :physics => session_arr[1][3],
      :protocol => session_arr[0][2],
      :pickups => true?(session_arr[1][5]),
      :date => parse_and_format_date(session_arr[1][1]),
      :races => get_races_hash(session_arr),
      :ranking => @ranking,
      :category => @category,
      :teams => @teams,
      :session_log => @file
    }

    session = Session.new(session_hash)
    rva_results = RvaCalculateResultsService.new(session).call

    if session.teams
      TeamPointsService.new(session, rva_results).add_points
    else
      StatsService.new(session, rva_results).add_stats
    end

    session
  end

  def get_races_hash(session_arr)
    session_races_arr = get_session_races_arr(session_arr)

    races_hash = {}
    num_races = 0
    session_races_arr.each do |race_arr|
      racer_entries = {}
      num_racer_entries = 0
      race_arr[2].each do |racer_entry_arr|
        racer_entry_hash = {
          :position => racer_entry_arr[0],
          :username => racer_entry_arr[1],
          :car_name => racer_entry_arr[2],
          :time => racer_entry_arr[3],
          :best_lap => racer_entry_arr[4],
          :finished => true?(racer_entry_arr[5]),
          :cheating => true?(racer_entry_arr[6])
        }

        racer_entries = racer_entries.merge(num_racer_entries.to_s => racer_entry_hash)
        num_racer_entries += 1
      end

      race_hash = {
        :track_name => race_arr[1][1],
        :racer_entries => racer_entries,
        :laps => race_arr[0][4],
        :total_racers => race_arr[1][2]
      }

      races_hash = races_hash.merge(num_races.to_s => race_hash)
      num_races += 1
    end

    races_hash
  end

  def get_session_races_arr(full_log)
    session_races_arr = []

    session_row_arr = nil
    results_row_arr = nil
    position_rows_arr = []

    racers = false
    count = 0
    full_log = full_log.drop(1)

    full_log.each do |row|
      if row[0] == '#' # skip headers
        count += 1
        next
      end

      if row[0] == 'Session'
        session_row_arr = row
      elsif row[0] == 'Results'
        results_row_arr = row
      else
        position_rows_arr << row
        racers = true
      end

      if racers && (full_log[count + 1].nil? || (full_log[count + 1][0] == 'Session') || (full_log[count + 1][0] == 'Results'))
        racers = false

        session_race_arr = [session_row_arr, results_row_arr, position_rows_arr]
        session_races_arr << session_race_arr

        position_rows_arr = []
      end

      count += 1
    end

    session_races_arr
  end

  # TODO: Check whether this csv corresponds to a Re-Volt session log
  def is_rv_session_log(_csv)
    true
  end
end

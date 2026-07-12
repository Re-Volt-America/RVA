class CsvImportSessionsService
  include ApplicationHelper

  require 'csv'
  require 'rva_calculate_results_service'
  require 'session_results_table'
  require 'stats_service'
  require 'team_points_service'

  def initialize(file, ranking, category, number, teams)
    @file = file
    @ranking = ranking
    @category = category
    @number = number
    @teams = teams
    @user_cache = {}
    @car_cache = {}
    @track_cache = {}
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
    csv = CSV.parse(read_file_content)

    unless is_rv_session_log(csv)
      return nil # FIXME: handle?
    end

    session_arr = []
    csv.each do |row|
      session_arr << row
    end

    ranking = Ranking.find { |r| r.id.to_s.eql?(@ranking) }
    season = ranking&.season
    host_name = true?(@teams) ? session_arr[1][2].partition(' ').last : session_arr[1][2]
    host_user = find_user_by_username(host_name)

    session_hash = {
      :number => ranking.sessions.size + 1,
      :hosts => [host_user].compact,
      :legacy_host => host_name,
      :version => session_arr[0][1],
      :physics => session_arr[1][3],
      :protocol => session_arr[0][2],
      :pickups => true?(session_arr[1][5]),
      :date => parse_and_format_date(session_arr[1][1]),
      :races => get_races_hash(session_arr, season),
      :ranking => ranking,
      :category => @category,
      :teams => @teams,
      :session_log => @file
    }

    session = Session.new(session_hash)
    rva_results = RvaCalculateResultsService.new(session).call
    session.results_data = SessionResultsTable.from_legacy_array(rva_results, session).as_serialized

    if session.teams
      TeamPointsService.new(session, rva_results).add_points
    else
      StatsService.new(session, rva_results).add_stats
    end

    session
  end

  def get_races_hash(session_arr, season)
    session_races_arr = get_session_races_arr(session_arr)

    races_hash = {}
    num_races = 0
    session_races_arr.each do |race_arr|
      racer_entries = {}
      num_racer_entries = 0
      race_arr[2].each do |racer_entry_arr|
        username = racer_entry_arr[1]
        car_name = racer_entry_arr[2]
        user = find_user_by_username(username)
        car = find_car_by_name(car_name, season)

        racer_entry_hash = {
          :position => racer_entry_arr[0],
          :user => user,
          :legacy_username => username,
          :car => car,
          :legacy_car_name => car_name,
          :time => racer_entry_arr[3],
          :best_lap => racer_entry_arr[4],
          :finished => true?(racer_entry_arr[5]),
          :cheating => true?(racer_entry_arr[6])
        }

        racer_entries = racer_entries.merge(num_racer_entries.to_s => racer_entry_hash)
        num_racer_entries += 1
      end

      track_name = race_arr[1][1]
      track = find_track_by_name(track_name, season)

      race_hash = {
        :track => track,
        :legacy_track_name => track_name,
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

  # Reads the raw CSV content regardless of whether @file is an uploaded file,
  # a Shrine attachment/Tempfile (background import) or a plain path/String.
  def read_file_content
    if @file.respond_to?(:read)
      @file.rewind if @file.respond_to?(:rewind)
      @file.read
    else
      File.read(@file)
    end
  end

  def find_user_by_username(username)
    return nil if username.nil?

    normalized = username.to_s.upcase
    return @user_cache[normalized] if @user_cache.key?(normalized)

    @user_cache[normalized] = User.where(:username => normalized).first
  end

  def find_car_by_name(car_name, season)
    return nil if car_name.nil? || season.nil?

    cache_key = "#{season.id}:#{car_name}"
    return @car_cache[cache_key] if @car_cache.key?(cache_key)

    @car_cache[cache_key] = Car.where(:name => car_name, :season => season).first
  end

  def find_track_by_name(track_name, season)
    return nil if track_name.nil? || season.nil?

    cache_key = "#{season.id}:#{track_name}"
    return @track_cache[cache_key] if @track_cache.key?(cache_key)

    tracks = Track.where(:season => season).to_a
    @track_cache[cache_key] = tracks.find { |t| t.name_variations.include?(track_name) }
  end
end

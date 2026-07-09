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
    csv = CSV.parse(read_uploaded_csv_content(@file))

    unless is_rv_session_log(csv)
      return nil # FIXME: handle?
    end

    session_arr = csv.reject { |row| blank_row?(row) }
    version_row = session_arr.find { |row| row[0] == '#' }
    session_row = session_arr.find { |row| row[0] == 'Session' }

    return nil if version_row.nil? || session_row.nil?

    ranking = Ranking.find { |r| r.id.to_s.eql?(@ranking) }
    season = ranking&.season
    host_name = extract_host_name(session_row[2])
    host_user = find_user_by_username(host_name)

    session_hash = {
      :number => ranking.sessions.size + 1,
      :hosts => [host_user].compact,
      :legacy_host => host_name,
      :version => version_row[1],
      :physics => session_row[3],
      :protocol => version_row[2],
      :pickups => true?(session_row[5]),
      :date => parse_and_format_date(session_row[1]),
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
      next unless complete_race?(race_arr[0], race_arr[1], race_arr[2])

      racer_entries = {}
      num_racer_entries = 0
      race_arr[2].each do |racer_entry_arr|
        next unless valid_racer_row?(racer_entry_arr)

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
    full_log = full_log.drop(1)

    full_log.each do |row|
      if blank_row?(row) || row[0] == '#'
        next
      end

      if row[0] == 'Session'
        if complete_race?(session_row_arr, results_row_arr, position_rows_arr)
          session_races_arr << [session_row_arr, results_row_arr, position_rows_arr]
          position_rows_arr = []
          results_row_arr = nil
        end

        session_row_arr = row
      elsif row[0] == 'Results'
        if complete_race?(session_row_arr, results_row_arr, position_rows_arr)
          session_races_arr << [session_row_arr, results_row_arr, position_rows_arr]
          position_rows_arr = []
        end

        results_row_arr = row
      else
        next unless valid_racer_row?(row)

        position_rows_arr << row
      end
    end

    if complete_race?(session_row_arr, results_row_arr, position_rows_arr)
      session_races_arr << [session_row_arr, results_row_arr, position_rows_arr]
    end

    session_races_arr
  end

  # TODO: Check whether this csv corresponds to a Re-Volt session log
  def is_rv_session_log(_csv)
    true
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

  private

  def read_uploaded_csv_content(file)
    if file.respond_to?(:read)
      file.rewind if file.respond_to?(:rewind)
      return file.read
    end

    if file.respond_to?(:tempfile) && file.tempfile.respond_to?(:read)
      file.tempfile.rewind if file.tempfile.respond_to?(:rewind)
      return file.tempfile.read
    end

    raise ArgumentError, 'Invalid uploaded file'
  end

  def blank_row?(row)
    row.nil? || row.all? { |value| value.to_s.strip.empty? }
  end

  def extract_host_name(raw_host_name)
    normalized_host_name = raw_host_name.to_s.strip
    return normalized_host_name unless true?(@teams)

    parsed_host_name = normalized_host_name.partition(' ').last.to_s.strip
    parsed_host_name.empty? ? normalized_host_name : parsed_host_name
  end

  def complete_race?(session_row_arr, results_row_arr, position_rows_arr)
    session_row_arr.present? && results_row_arr.present? && position_rows_arr.any?
  end

  def valid_racer_row?(row)
    return false if row.nil?
    return false unless row[0].to_s.match?(/\A\d+\z/)
    return false unless row.values_at(1, 2, 3, 4, 5, 6).all? { |value| value.present? }

    %w(true false).include?(row[5].to_s.downcase) && %w(true false).include?(row[6].to_s.downcase)
  end
end

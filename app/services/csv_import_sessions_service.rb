class CsvImportSessionsService
  include ApplicationHelper

  require 'csv'
  require 'rva_calculate_results_service'
  require 'user_stats_service'

  def initialize(file, ranking, category, number, teams)
    @file = file
    @ranking = ranking
    @category = category
    @number = number
    @teams = teams
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
      :number => @number,
      :host => session_arr[1][2],
      :version => session_arr[0][1],
      :physics => session_arr[1][3],
      :protocol => session_arr[0][2],
      :pickups => true?(session_arr[1][5]),
      :date => Date.strptime(session_arr[1][1], '%D'),
      :races => get_races_hash(session_arr),
      :ranking => @ranking,
      :category => @category,
      :teams => @teams,
      :session_log => @file
    }

    session = Session.new(session_hash)
    return session if session.teams

    # Keep a record of this session's racer result entries for season/ranking leaderboard calculations

    rva_results = RvaCalculateResultsService.new(session).call

    racer_result_entries = []
    num_entries = 0
    count = 0
    rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      unless row[3].is_a?(User)
        count += 1
        next
      end

      user = row[3]
      positions = row[4]
      average_position = row[5].to_f
      positions_sum = positions.map(&:to_i).sum
      obtained_points = row[6].to_i
      official_score = row[9].to_f
      race_count = row[7].to_i
      participation_multiplier = row[8].to_f

      racer_result_entry_hash = {
        :username => user.username,
        :country => user.country,
        :race_count => race_count,
        :positions_sum => positions_sum,
        :average_position => average_position,
        :obtained_points => obtained_points,
        :official_score => official_score,
        :participation_multiplier => participation_multiplier,
        :team => nil # TODO: Extend support for team sessions
      }

      racer_result_entries << RacerResultEntry.new(racer_result_entry_hash)
      count += 1
      num_entries += 1
    end

    session.racer_result_entries = racer_result_entries
    session.update

    UserStatsService.new.add_stats(rva_results) unless session.nil?

    update_ranking(session)
    update_season(session)

    session
  end

  # Add the Session results to its Ranking
  def update_ranking(session)
    ranking = session.ranking

    session_entries = session.racer_result_entries
    ranking_entries = ranking.racer_result_entries

    session_entries.each do |session_entry|
      ranking_entry = ranking_entries.find { |e| e.username.eql?(session_entry.username) }

      if ranking_entry.nil?
        se_hash = {
          :username => session_entry.username,
          :country => session_entry.country,
          :race_count => session_entry.race_count,
          :session_count => 1,
          :positions_sum => session_entry.positions_sum,
          :average_position => session_entry.average_position,
          :obtained_points => session_entry.obtained_points,
          :official_score => session_entry.official_score,
          :participation_multiplier => session_entry.participation_multiplier,
          :team => session_entry.team
        }

        ranking_entries << RacerResultEntry.new(se_hash)
      else
        ranking_entry.country = session_entry.country
        ranking_entry.session_count += 1
        ranking_entry.race_count += session_entry.race_count
        ranking_entry.positions_sum += session_entry.positions_sum
        ranking_entry.average_position += (ranking_entry.positions_sum.to_f / (ranking_entry.race_count.nonzero? || 1)).round(2)
        ranking_entry.obtained_points += session_entry.obtained_points.to_i
        ranking_entry.official_score += session_entry.official_score.to_f
        ranking_entry.participation_multiplier = (ranking_entry.race_count / (ranking_entry.session_count * 20).nonzero? || 1).round(2)
      end
    end

    ranking.racer_result_entries = ranking_entries.sort_by { |e| e.official_score }.reverse!
    ranking.update!
  end

  # Add the Session results to its Season
  def update_season(session)
    season = session.ranking.season

    session_entries = session.racer_result_entries
    season_entries = season.racer_result_entries

    session_entries.each do |session_entry|
      season_entry = season_entries.find { |e| e.username.eql?(session_entry.username) }

      if season_entry.nil?
        session_entry_hash = {
          :username => session_entry.username,
          :country => session_entry.country,
          :session_count => 1,
          :race_count => session_entry.race_count,
          :positions_sum => session_entry.positions_sum,
          :average_position => session_entry.average_position,
          :obtained_points => session_entry.obtained_points,
          :official_score => session_entry.official_score,
          :participation_multiplier => session_entry.participation_multiplier,
          :team => session_entry.team
        }

        season_entries << RacerResultEntry.new(session_entry_hash)
      else
        season_entry.country = session_entry.country
        season_entry.session_count += 1
        season_entry.race_count += session_entry.race_count
        season_entry.positions_sum += session_entry.positions_sum
        season_entry.average_position += (season_entry.positions_sum.to_f / (season_entry.race_count.nonzero? || 1)).round(2)
        season_entry.obtained_points += session_entry.obtained_points.to_i
        season_entry.official_score += session_entry.official_score.to_f
        season_entry.participation_multiplier = (season_entry.race_count / (season_entry.session_count * 20).nonzero? || 1).round(2)
      end
    end

    season.racer_result_entries = season_entries.sort_by { |e| e.official_score }.reverse!
    season.update!
  end

  def get_races_hash(session_arr)
    session_races_arr = get_session_races_arr(session_arr)

    races_hash = {}
    num_races = 0
    session_races_arr.each do |race_arr|
      racer_entries = {}
      num_racer_entries = 0
      race_arr[2].each do |racer_entry_arr|
        car = Car.find { |c| c.name.eql?(racer_entry_arr[2]) } # consider matching season with @ranking

        byebug if car.nil? # FIXME: debug

        racer_entry_hash = {
          :position => racer_entry_arr[0],
          :username => racer_entry_arr[1],
          :car_id => car.id,
          :time => racer_entry_arr[3],
          :best_lap => racer_entry_arr[4],
          :finished => true?(racer_entry_arr[5]),
          :cheating => true?(racer_entry_arr[6])
        }

        racer_entries = racer_entries.merge(num_racer_entries.to_s => racer_entry_hash)
        num_racer_entries += 1
      end

      track = Track.find { |t| race_arr[1][1].start_with?(t.name) }
      byebug if track.nil? # FIXME: debug

      race_hash = {
        :track_id => track.id,
        :racer_entries => racer_entries,
        :laps => race_arr[0][4],
        :racers_count => race_arr[1][2]
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
    full_log.drop(1).each do |row|
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

    session_race_arr = [session_row_arr, results_row_arr, position_rows_arr]
    session_races_arr << session_race_arr

    session_races_arr
  end

  # TODO: Check whether this csv corresponds to a Re-Volt session log
  def is_rv_session_log(_csv)
    true
  end
end

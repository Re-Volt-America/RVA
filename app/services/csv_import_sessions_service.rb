class CsvImportSessionsService
  include ApplicationHelper

  require 'csv'

  CSV_TYPE = "application/vnd.ms-excel".freeze
  XLSM_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze

  def call(file, ranking, teams)
    csv = CSV.parse(File.open(file))

    unless is_rv_session_log(csv)
      return nil
    end

    full_log = []
    csv.each do |row|
      full_log << row
    end

    session_hash = {
        :host => full_log[1][2],
        :version => full_log[0][1],
        :physics => full_log[1][3],
        :protocol => full_log[0][2],
        :pickups => true?(full_log[1][5]),
        :date => Date.strptime(full_log[1][1], "%D"),
        :races => get_races_hash(full_log),
        :ranking => ranking,
        :teams => teams,
    }

    Session.new(session_hash)
  end

  def get_races_hash(full_log)
    sample_car_id = Car.first.id

    session_races_arr = get_session_races_arr(full_log)

    races_hash = {}
    num_races = 0
    session_races_arr.each do |r|

      racer_entries = {}
      num_racer_entries = 0
      r[1].each do |entry|
        racer_entry_hash = {
            :position => entry[0],
            :name => entry[1],
            :car_id => sample_car_id,
            :time => entry[3],
            :best_lap => entry[4],
            :finished => true?(entry[5]),
            :cheating => true?(entry[6])
        }

        racer_entries = racer_entries.merge(num_racer_entries.to_s => racer_entry_hash)
        num_racer_entries += 1
      end

      race_hash = {
          :track_id => Track.first.id, # FIXME: get actual tracks
          :racer_entries => racer_entries,
          :laps => 3, # FIXME: look for real lap counts
          :racers_count => r[0][2]
      }

      races_hash = races_hash.merge(num_races.to_s => race_hash)
      num_races += 1
    end

    races_hash
  end

  def get_session_races_arr(full_log)
    session_races_arr = []
    racers_arr = []
    race_arr = []
    first = true

    full_log.drop(2).each do |row|
      if row[0] == "#" # skip headers
        next
      end

      if not first and row[0] == "Results"
        race_arr << racers_arr
        session_races_arr << race_arr
        race_arr = []
        racers_arr = []
        race_arr << row
      else
        if row[0] == "Results"
          race_arr << row
        else
          racers_arr << row
        end

        first = false
      end
    end

    session_races_arr
  end

  # TODO: Check whether this csv corresponds to a Re-Volt session log
  def is_rv_session_log(csv)
    true
  end
end

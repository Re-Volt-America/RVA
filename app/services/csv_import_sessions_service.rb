class CsvImportSessionsService
  include ApplicationHelper

  require 'csv'

  CSV_TYPE = "application/vnd.ms-excel".freeze
  XLSM_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze

  def call(file, ranking, teams)
    file = File.open(file)
    csv = CSV.parse(file)

    unless is_rv_session_log(csv)
      return nil
    end

    full_log = []
    session_races_arr = []

    # @see https://github.com/Re-Volt-America/RVA-Points/blob/f17b2fcf0e66470665622002fcce0207c5652597/rva_points_app/session_log.py#L326
    csv.each do |row|
      full_log << row
    end

    host = full_log[1][2]
    version = full_log[0][1]
    physics = full_log[1][3]
    protocol = full_log[0][2]
    date = Date.strptime(full_log[1][1], "%D")
    pickups = true?(full_log[1][5])

    race_arr = []
    racers_arr = []

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

    sample_car_id = Car.first.id

    races_hash = {}
    num_races = 0
    session_races_arr.each do |r|
      racers_count = r[0][2]

      num_racer_entries = 0
      racer_entries = {}
      r[1].each do |entry|
        racer_entry_hash = {}
        racer_entry_hash[:position] = entry[0]
        racer_entry_hash[:name] = entry[1]
        racer_entry_hash[:car_id] = sample_car_id # FIXME: look for the exact car...
        racer_entry_hash[:time] = entry[3]
        racer_entry_hash[:best_lap] = entry[4]
        racer_entry_hash[:finished] = true?(entry[5])
        racer_entry_hash[:cheating] = true?(entry[6])

        racer_entries = racer_entries.merge(num_racer_entries.to_s => racer_entry_hash)
        num_racer_entries += 1
      end

      race_hash = {}
      race_hash[:track_id] = Track.first.id
      race_hash[:racer_entries] = racer_entries
      race_hash[:laps] = 3 # FIXME: look for real lap counts
      race_hash[:racers_count] = racers_count

      races_hash = races_hash.merge(num_races.to_s => race_hash)
      num_races += 1
    end

    session_hash = {}
    session_hash[:host] = host
    session_hash[:version] = version
    session_hash[:physics] = physics
    session_hash[:protocol] = protocol
    session_hash[:pickups] = pickups
    session_hash[:date] = date
    session_hash[:teams] = teams
    session_hash[:races] = races_hash
    session_hash[:ranking] = ranking

    Session.new(session_hash)
  end

  # Check whether this csv corresponds to a Re-Volt session log
  def is_rv_session_log(csv)
    true
  end
end

namespace :rva do
  desc "Backfill session host/track/user/car references from legacy name fields"
  task backfill_session_refs: :environment do
    user_cache = {}
    track_cache = {}
    car_cache = {}

    def cached_user(name, cache)
      return nil if name.nil? || name.to_s.strip.empty?

      key = name.to_s.upcase
      return cache[key] if cache.key?(key)

      cache[key] = User.where(:username => key).first
    end

    def cached_track(name, season, cache)
      return nil if name.nil? || name.to_s.strip.empty? || season.nil?

      key = "#{season.id}:#{name}"
      return cache[key] if cache.key?(key)

      tracks = Track.where(:season => season).to_a
      cache[key] = tracks.find { |t| t.name_variations.include?(name) }
    end

    def cached_car(name, season, cache)
      return nil if name.nil? || name.to_s.strip.empty? || season.nil?

      key = "#{season.id}:#{name}"
      return cache[key] if cache.key?(key)

      cache[key] = Car.where(:name => name, :season => season).first
    end

    totals = {
      :sessions_scanned => 0,
      :hosts_linked => 0,
      :tracks_linked => 0,
      :users_linked => 0,
      :cars_linked => 0,
      :sessions_saved => 0,
      :errors => 0
    }

    Session.each do |session|
      totals[:sessions_scanned] += 1
      changed = false
      season = session.ranking&.season

      if session.host.nil? && session.legacy_host.present?
        host = cached_user(session.legacy_host, user_cache)
        if host
          session.host = host
          totals[:hosts_linked] += 1
          changed = true
        end
      end

      session.races.each do |race|
        if race.track.nil? && race.legacy_track_name.present?
          track = cached_track(race.legacy_track_name, season, track_cache)
          if track
            race.track = track
            totals[:tracks_linked] += 1
            changed = true
          end
        end

        race.racer_entries.each do |entry|
          if entry.user.nil? && entry.legacy_username.present?
            user = cached_user(entry.legacy_username, user_cache)
            if user
              entry.user = user
              totals[:users_linked] += 1
              changed = true
            end
          end

          if entry.car.nil? && entry.legacy_car_name.present?
            car = cached_car(entry.legacy_car_name, season, car_cache)
            if car
              entry.car = car
              totals[:cars_linked] += 1
              changed = true
            end
          end
        end
      end

      next unless changed

      begin
        session.save!
        totals[:sessions_saved] += 1
      rescue => e
        totals[:errors] += 1
        puts "Session #{session.id} failed: #{e.class} #{e.message}"
      end
    end

    puts "Sessions scanned: #{totals[:sessions_scanned]}"
    puts "Hosts linked: #{totals[:hosts_linked]}"
    puts "Tracks linked: #{totals[:tracks_linked]}"
    puts "Users linked: #{totals[:users_linked]}"
    puts "Cars linked: #{totals[:cars_linked]}"
    puts "Sessions saved: #{totals[:sessions_saved]}"
    puts "Errors: #{totals[:errors]}"
  end

  desc "Backfill persisted results_data for sessions missing it"
  task backfill_session_results: :environment do
    require 'rva_calculate_results_service'
    require 'session_results_table'

    scanned = 0
    updated = 0
    errors = 0

    Session.each do |session|
      scanned += 1
      if session.results_data.is_a?(Hash) && session.results_data['rows'].present?
        next
      end

      begin
        if session.results_data.is_a?(Array)
          rva_results = session.results_data
        else
          rva_results = RvaCalculateResultsService.new(session).call
        end

        session.results_data = SessionResultsTable.from_legacy_array(rva_results, session).as_serialized
        session.save!
        updated += 1
      rescue => e
        errors += 1
        puts "Session #{session.id} failed: #{e.class} #{e.message}"
      end
    end

    puts "Sessions scanned: #{scanned}"
    puts "Sessions updated: #{updated}"
    puts "Errors: #{errors}"
  end
end

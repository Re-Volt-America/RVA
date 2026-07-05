namespace :rva do
  # Maps old raw document keys (written before the *_reference schema existed)
  # onto the field names the current models actually persist. Runs at the raw
  # collection level on purpose: $rename can't reach into embedded arrays, and
  # loading through Mongoid would trip the very validations we're trying to make
  # pass.
  desc "Rename legacy embedded session keys (host/track_name/username/car_name) to their legacy_* fields"
  task normalize_legacy_sessions: :environment do
    collection = Session.collection

    scanned = 0
    migrated = 0

    # Move an old key onto its legacy_* field within a hash, in place.
    # Only fills the legacy field if it's currently blank, but always drops
    # the stale key so re-runs are no-ops.
    move_key = lambda do |hash, old_key, new_key|
      return false unless hash.key?(old_key)

      old_value = hash.delete(old_key)
      hash[new_key] = old_value if hash[new_key].to_s.strip.empty?
      true
    end

    collection.find.each do |doc|
      scanned += 1
      set_ops = {}
      unset_ops = {}

      # Session-level host: raw string "host" -> legacy_host.
      # belongs_to :host persists as host_id, so a bare "host" is always legacy.
      if doc['host'].is_a?(String)
        set_ops['legacy_host'] = doc['host'] if doc['legacy_host'].to_s.strip.empty?
        unset_ops['host'] = ''
      end

      races = doc['races']
      if races.is_a?(Array)
        races_changed = false

        new_races = races.map do |race|
          race = race.dup
          races_changed = true if move_key.call(race, 'track_name', 'legacy_track_name')

          entries = race['racer_entries']
          if entries.is_a?(Array)
            race['racer_entries'] = entries.map do |entry|
              entry = entry.dup
              races_changed = true if move_key.call(entry, 'username', 'legacy_username')
              races_changed = true if move_key.call(entry, 'car_name', 'legacy_car_name')
              entry
            end
          end

          race
        end

        set_ops['races'] = new_races if races_changed
      end

      next if set_ops.empty? && unset_ops.empty?

      update = {}
      update['$set'] = set_ops unless set_ops.empty?
      update['$unset'] = unset_ops unless unset_ops.empty?

      collection.update_one({ '_id' => doc['_id'] }, update)
      migrated += 1
    end

    puts "Sessions scanned: #{scanned}"
    puts "Sessions normalized: #{migrated}"
  end

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

      if session.hosts.empty? && session.legacy_host.present?
        host = cached_user(session.legacy_host, user_cache)
        if host
          session.hosts = [host]
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
    skipped = 0

    # FORCE=1 recomputes results_data even when rows already exist. Needed after
    # normalizing legacy sessions: results persisted from the old data have stale
    # (often null) track cells baked in and would otherwise be skipped.
    force = ENV['FORCE'].present?

    $stdout.sync = true
    # Load ids up front instead of holding a live cursor open across the slow
    # per-session recompute. This was timing out as CursorNotFound.
    session_ids = Session.all.pluck(:id)
    total = session_ids.size
    started = Time.now
    puts "Backfilling results for #{total} sessions (force=#{force})..."

    session_ids.each do |id|
      session = Session.find(id)
      scanned += 1
      if !force && session.results_data.is_a?(Hash) && session.results_data['rows'].present?
        next
      end

      begin
        if !force && session.results_data.is_a?(Array)
          rva_results = session.results_data
        else
          rva_results = RvaCalculateResultsService.new(session).call
        end

        session.results_data = SessionResultsTable.from_legacy_array(rva_results, session).as_serialized
        session.save!
        updated += 1
      rescue Mongoid::Errors::Validations => e
        skipped += 1
        puts "  [#{scanned}/#{total}] Session ##{session.number} (#{session.id}) skipped (invalid): #{e.summary}"
      rescue => e
        errors += 1
        puts "  [#{scanned}/#{total}] Session ##{session.number} (#{session.id}) failed: #{e.class} #{e.message}"
      end

      if (scanned % 20).zero? || scanned == total
        puts "  [#{scanned}/#{total}] elapsed #{(Time.now - started).round}s (updated: #{updated}, skipped: #{skipped}, errors: #{errors})"
      end
    end

    puts "Sessions scanned: #{scanned}"
    puts "Sessions updated: #{updated}"
    puts "Sessions skipped (invalid data): #{skipped}"
    puts "Errors: #{errors}"
  end

  desc "Full legacy migration: normalize keys, then link refs, then backfill results"
  task migrate_legacy_sessions: :environment do
    # Recompute results from freshly-normalized data so track cells resolve properly.
    ENV['FORCE'] ||= 'true'

    %w[normalize_legacy_sessions backfill_session_refs backfill_session_results].each do |name|
      puts "\n== rva:#{name} =="
      Rake::Task["rva:#{name}"].invoke
    end
  end
end

# frozen_string_literal: true

namespace :trophies do
  desc 'Recompute trophies for every user, awarding (and notifying) any newly-earned ones. ' \
       'Run this after adding new trophy definitions or to backfill existing users.'
  task :recompute => :environment do
    log = ->(msg) { puts "[#{Time.now.strftime('%H:%M:%S')}] #{msg}"; $stdout.flush }
    started = Time.now

    # One shared snapshot of the user-independent data (leaderboard, cars,
    # ranking winners) for the whole run.
    TrophyContext.reset_shared_caches!

    # Preload every session once and group it by participant, so evaluating a
    # player never issues a per-user query (that per-user work inside a live
    # User cursor is what timed the cursor out and made this crawl).
    log.call "Preloading sessions..."
    sessions_by_user = Hash.new { |h, k| h[k] = [] }
    session_total = 0
    Session.without(:session_log_data, :results_data).each do |session|
      session_total += 1
      session.racer_result_entries.each { |entry| sessions_by_user[entry.username] << session }
    end
    log.call "Loaded #{session_total} sessions across #{sessions_by_user.size} participants."

    # Pull the full id list up front; iterating ids (not a live cursor) means no
    # cursor can expire while we work.
    user_ids = User.all.pluck(:id)
    total = user_ids.size
    log.call "Evaluating #{total} players..."

    awarded = processed = skipped = players = 0

    user_ids.each do |uid|
      processed += 1
      user = User.find(uid)
      stats = user.stats

      if stats.nil? || (stats.session_count.to_i.zero? && stats.race_count.to_i.zero?)
        skipped += 1
      else
        newly = TrophyService.sync(user, :sessions => sessions_by_user[user.username])
        unless newly.empty?
          players += 1
          awarded += newly.size
          log.call "  #{user.username} +#{newly.size}: #{newly.map(&:key).join(', ')}"
        end
      end

      if (processed % 25).zero? || processed == total
        log.call "[#{processed}/#{total}] processed | #{awarded} trophies to #{players} players | #{skipped} inactive | #{(Time.now - started).round(1)}s"
      end
    end

    log.call "Done in #{(Time.now - started).round(1)}s. Awarded #{awarded} trophies to #{players} players (#{skipped} inactive skipped)."
  end

  desc 'List every defined trophy (key, tier, icon).'
  task :list => :environment do
    Trophy.all.sort_by(&:tier_index).each do |trophy|
      puts format('%-20s  %-9s  %-18s  %s', trophy.key, trophy.tier, trophy.icon, trophy.name)
    end
    puts "\n#{Trophy.all.size} trophies defined."
  end

  desc 'Force-award EVERY defined trophy to a user, ignoring the conditions. ' \
       'For previewing the Trophy Case / notifications. Usage: rake "trophies:grant_all[BGM]"'
  task :grant_all, [:username] => :environment do |_t, args|
    username = args[:username].to_s.upcase
    abort 'Usage: rake "trophies:grant_all[USERNAME]"' if username.empty?

    user = User.where(:username => username).first
    abort "No user found with username #{username}" if user.nil?

    granted = 0
    Trophy.all.each do |trophy|
      next unless user.award_trophy(trophy.key) # false if already held

      granted += 1
      Notification.create(:user => user, :kind => 'trophy', :trophy_key => trophy.key.to_s)
    end
    user.save

    puts "Granted #{granted} new trophies to #{user.username} " \
         "(#{Trophy.all.size} defined; now holds #{user.trophies.size})."
  end

  desc 'Remove ALL trophies (and their notifications) from a user. ' \
       'Inverse of grant_all. Usage: rake "trophies:revoke_all[BGM]"'
  task :revoke_all, [:username] => :environment do |_t, args|
    username = args[:username].to_s.upcase
    abort 'Usage: rake "trophies:revoke_all[USERNAME]"' if username.empty?

    user = User.where(:username => username).first
    abort "No user found with username #{username}" if user.nil?

    trophy_count = user.trophies.size
    user.trophies.destroy_all
    user.save

    notif_count = Notification.where(:user_id => user.id, :kind => 'trophy').delete_all

    puts "Removed #{trophy_count} trophies and #{notif_count} trophy notifications from #{user.username}."
  end

  desc 'Grant ONE trophy to a user (use this for manual trophies such as ' \
       'official_business or translator). Usage: rake "trophies:grant[BGM,translator]"'
  task :grant, [:username, :key] => :environment do |_t, args|
    username = args[:username].to_s.upcase
    key = args[:key].to_s
    abort 'Usage: rake "trophies:grant[USERNAME,trophy_key]"' if username.empty? || key.empty?

    user = User.where(:username => username).first
    abort "No user found with username #{username}" if user.nil?
    abort "No trophy defined with key '#{key}'" unless Trophy.exists?(key)

    if user.award_trophy(key)
      user.save
      Notification.create(:user => user, :kind => 'trophy', :trophy_key => key)
      puts "Granted '#{key}' to #{user.username}."
    else
      puts "#{user.username} already holds '#{key}'."
    end
  end

  desc 'Remove ONE trophy (and its notification) from a user. ' \
       'Usage: rake "trophies:revoke[BGM,translator]"'
  task :revoke, [:username, :key] => :environment do |_t, args|
    username = args[:username].to_s.upcase
    key = args[:key].to_s
    abort 'Usage: rake "trophies:revoke[USERNAME,trophy_key]"' if username.empty? || key.empty?

    user = User.where(:username => username).first
    abort "No user found with username #{username}" if user.nil?

    removed = user.trophies.where(:key => key).destroy_all
    user.save
    Notification.where(:user_id => user.id, :kind => 'trophy', :trophy_key => key).delete_all

    puts "Removed #{removed} '#{key}' trophy from #{user.username}."
  end
  desc 'DESTRUCTIVE: remove every trophy (and all trophy notifications) from ' \
       'ALL players. Usage: rake trophies:wipe'
  task :wipe => :environment do
    users = 0
    trophies = 0

    User.where(:"trophies.0".exists => true).pluck(:id).each do |uid|
      user = User.find(uid)
      next if user.trophies.empty?

      trophies += user.trophies.size
      user.trophies.destroy_all
      user.save
      users += 1
    end

    notifs = Notification.where(:kind => 'trophy').delete_all

    puts "Wiped #{trophies} trophies from #{users} players and deleted #{notifs} trophy notifications."
  end

end

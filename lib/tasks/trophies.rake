# frozen_string_literal: true

namespace :trophies do
  desc 'Recompute trophies for every user, awarding (and notifying) any newly-earned ones. ' \
       'Run this after adding new trophy definitions or to backfill existing users.'
  task :recompute => :environment do
    # Build the shared leaderboard / car-multiplier snapshot once for the whole
    # run (points and cars don't change while we award trophies).
    TrophyContext.reset_shared_caches!

    total = User.count
    awarded = 0
    processed = 0
    skipped = 0

    User.all.each do |user|
      processed += 1

      # Players who have never raced can't satisfy any auto trophy, so skip the
      # (indexed, but still real) history lookups entirely.
      stats = user.stats
      if stats.nil? || (stats.session_count.to_i.zero? && stats.race_count.to_i.zero?)
        skipped += 1
        next
      end

      awarded += TrophyService.sync(user).size
      print "\r[#{processed}/#{total}] processed, #{awarded} awarded, #{skipped} inactive skipped" if (processed % 20).zero?
    end

    puts "\nDone. Processed #{processed} users (#{skipped} inactive skipped), awarded #{awarded} new trophies."
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

    User.where(:"trophies.0".exists => true).each do |user|
      trophies += user.trophies.size
      user.trophies.destroy_all
      user.save
      users += 1
    end

    notifs = Notification.where(:kind => 'trophy').delete_all

    puts "Wiped #{trophies} trophies from #{users} players and deleted #{notifs} trophy notifications."
  end

end

# frozen_string_literal: true

namespace :trophies do
  desc 'Recompute trophies for every user, awarding (and notifying) any newly-earned ones. ' \
       'Run this after adding new trophy definitions or to backfill existing users.'
  task :recompute => :environment do
    total = User.count
    awarded = 0
    processed = 0

    User.all.each do |user|
      newly = TrophyService.sync(user)
      awarded += newly.size
      processed += 1
      print "\r[#{processed}/#{total}] users processed, #{awarded} trophies awarded" if (processed % 20).zero?
    end

    puts "\nDone. Processed #{processed} users, awarded #{awarded} new trophies."
  end

  desc 'List every defined trophy (key, tier, icon).'
  task :list => :environment do
    Trophy.all.sort_by(&:tier_index).each do |trophy|
      puts format('%-20s  %-9s  %-18s  %s', trophy.key, trophy.tier, trophy.icon, trophy.name)
    end
    puts "\n#{Trophy.all.size} trophies defined."
  end
end

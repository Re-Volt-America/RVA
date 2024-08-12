namespace :users do
  desc "Set all users' locales to the default app locale"
  task :reset_locales => :environment do
    User.each do |u|
      u.locale = I18n.default_locale
      u.update!
    end
  end

  desc 'Set all stats to zero for all users'
  task :clear_stats => :environment do
    User.each do |u|
      u.stats.race_wins = 0
      u.stats.race_win_rate = 0.0
      u.stats.race_podiums = 0
      u.stats.race_count = 0
      u.stats.positions_sum = 0
      u.stats.session_wins = 0
      u.stats.session_win_rate = 0.0
      u.stats.session_podiums = 0
      u.stats.session_count = 0
      u.stats.average_position = 0.0
      u.stats.participation_rate = 0.0
      u.stats.official_score = 0.0
      u.stats.obtained_points = 0

      u.update!
    end
  end

  desc 'Set all stats to zero for a determined user'
  task :clear_user_stats, [:username] => :environment do |_t, args|
    return if args[:username].nil?

    u = User.find { |u| u.username.downcase.eql?(args[:username].downcase) }

    return if u.nil?

    u.stats.race_wins = 0
    u.stats.race_win_rate = 0.0
    u.stats.race_podiums = 0
    u.stats.race_count = 0
    u.stats.positions_sum = 0
    u.stats.session_wins = 0
    u.stats.session_win_rate = 0.0
    u.stats.session_podiums = 0
    u.stats.session_count = 0
    u.stats.average_position = 0.0
    u.stats.participation_rate = 0.0
    u.stats.official_score = 0.0
    u.stats.obtained_points = 0

    u.update!
  end
end

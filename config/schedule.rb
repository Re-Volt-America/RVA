# Use this file to easily define all of your cron jobs.
# It''s helpful, but not entirely necessary to understand cron syntax (it is).

# Learn more: http://github.com/javan/whenever

set :output, 'log/cron_log.log'
set :environment, ENV.fetch('RAILS_ENV', :production)

# Generate today's tracklist JSON daily at 2 AM
every 1.day, at: '2:00 am' do
  runner 'script/generate_today_tracklist.rb', output: 'log/cron_log.log'
end

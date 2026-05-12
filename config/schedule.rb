# Use this file to easily define all of your cron jobs.
# It's helpful, but not entirely necessary to understand cron syntax (it is).

# Learn more: http://github.com/javan/whenever

set :output, 'log/cron_log.log'
set :environment, ENV.fetch('RAILS_ENV', :production)

# Generate today's tracklist JSON daily at 2 AM
every 1.day, at: '2:00 am' do
  runner 'script/generate_api_json.rb', output: 'log/cron_log.log'
end

# Alternative: generate weekly at 1 AM every Monday for weekly-schedule.json
every :monday, at: '1:00 am' do
  runner 'script/generate_api_json.rb', output: 'log/cron_log.log'
end

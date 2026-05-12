# Script to generate public/api JSON files for the bot
require 'fileutils'

dir = Rails.root.join('public', 'api')
FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

weekly = WeeklySchedule.desc(:created_at).first
if weekly.nil?
  puts 'no weekly schedules found'
  exit 0
end

base = ENV['RVA_BASE_URL'] || 'http://localhost:3000'

payload = {
  id: weekly.id.to_s,
  start_date: weekly.start_date,
  generated_at: Time.now,
  tracklists_count: weekly.track_lists.size,
  image_url_template: "#{base}/api/tracklist/{weekly_id}/{index}.png",
  example_image_url: "#{base}/api/tracklist/#{weekly.id}/0.png"
}
File.write(dir.join('weekly-schedule.json'), JSON.pretty_generate(payload.as_json))

start_date = weekly.start_date || Date.today
index = (Date.today - start_date).to_i

payload2 = {
  date: Date.today,
  weekly_schedule_id: weekly.id.to_s,
  tracklist_index: index,
  image_url: "#{base}/api/tracklist/#{weekly.id}/#{index}.png"
}

File.write(dir.join('today-track-list.json'), JSON.pretty_generate(payload2.as_json))

puts 'wrote files'

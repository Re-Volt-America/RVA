# Script to generate public/api/today-track-list.json from already-generated tracklist images
require 'fileutils'

api_dir = Rails.root.join('public', 'api')
FileUtils.mkdir_p(api_dir) unless Dir.exist?(api_dir)

weekly = WeeklySchedule.desc(:created_at).first
if weekly.nil?
  puts 'no weekly schedules found'
  exit 0
end

base = ENV['RVA_BASE_URL'] || 'http://localhost:3000'

start_date = weekly.start_date || Date.today
index = (Date.today - start_date).to_i

today_track_list = weekly.track_lists[index] || weekly.track_lists.first
current_class = today_track_list&.category
class_name = current_class ? ApplicationController.helpers.localized_category_name(current_class) : nil

# Look for the already-generated tracklist image for today
# Images are typically stored in public/uploads/tracklists/ 
tracklist_images_dir = Rails.root.join('public', 'uploads', 'tracklists')

# Try to find today's tracklist image by index
image_filename = "tracklist-#{index + 1}.png"
image_path = tracklist_images_dir.join(image_filename)

# If image exists, use it; otherwise fall back to URL template
if File.exist?(image_path)
  image_url = "#{base}/uploads/tracklists/#{image_filename}"
  puts "Found existing tracklist image: #{image_path}"
else
  # Fallback: use URL template (image may be generated on-demand)
  image_url = "#{base}/api/tracklist/#{weekly.id}/#{index}.png"
  puts "Image not found at #{image_path}, using URL template"
end

payload = {
  date: Date.today,
  weekly_schedule_id: weekly.id.to_s,
  tracklist_index: index,
  class_id: current_class,
  class_name: class_name,
  image_url: image_url
}

File.write(api_dir.join('today-track-list.json'), JSON.pretty_generate(payload.as_json))

puts "Generated today tracklist JSON (index #{index}) for #{Date.today}"
puts "Class: #{class_name} (#{current_class})"
puts "Image URL: #{image_url}"

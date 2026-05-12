# Script to generate public/api JSON files from already-generated tracklist images
require 'fileutils'

dir = Rails.root.join('public', 'api')
FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

weekly = WeeklySchedule.desc(:created_at).first
if weekly.nil?
  puts 'no weekly schedules found'
  exit 0
end

base = ENV['RVA_BASE_URL'] || 'http://localhost:3000'
tracklist_images_dir = Rails.root.join('public', 'uploads', 'tracklists')

# Generate weekly schedule JSON with all tracklist image URLs
tracklist_urls = []
weekly.track_lists.each_with_index do |tl, idx|
  image_filename = "tracklist-#{idx + 1}.png"
  image_path = tracklist_images_dir.join(image_filename)
  
  if File.exist?(image_path)
    image_url = "#{base}/uploads/tracklists/#{image_filename}"
  else
    # Fallback to template
    image_url = "#{base}/api/tracklist/#{weekly.id}/#{idx}.png"
  end
  
  tracklist_urls << {
    index: idx,
    image_url: image_url
  }
end

payload = {
  id: weekly.id.to_s,
  start_date: weekly.start_date,
  generated_at: Time.now,
  tracklists_count: weekly.track_lists.size,
  tracklists: tracklist_urls
}

File.write(dir.join('weekly-schedule.json'), JSON.pretty_generate(payload.as_json))
puts "Generated weekly schedule JSON with #{tracklist_urls.size} tracklist images"


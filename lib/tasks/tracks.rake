namespace :rva do
  desc "Set missing active flags to true for Track"
  task set_active_tracks: :environment do
    puts "Setting active=true for Track where missing..."
    begin
      Track.where(:active.exists => false).update_all(active: true)
      puts "Tracks updated."
    rescue => e
      puts "Error updating tracks: #{e.message}"
      raise
    end
  end
end
namespace :tracks do
  desc "Set all tracks' authors to '-'"
  task :reset_authors => :environment do
    Track.each do |t|
      t.author = '-'
      t.update!
    end
  end

  desc "Set all tracks' average_lap_time to 0"
  task :reset_average_lap_times => :environment do
    Track.each do |t|
      t.average_lap_time = 0
      t.update!
    end
  end
end

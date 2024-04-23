namespace :tracks do
  desc "Set all tracks' authors to '-'"
  task reset_authors: :environment do
    Track.each do |t|
      t.author = "-"
      t.update!
    end
  end

  desc "Set all tracks' average_lap_time to 0"
  task reset_average_lap_times: :environment do
    Track.each do |t|
      t.average_lap_time = 0
      t.update!
    end
  end
end

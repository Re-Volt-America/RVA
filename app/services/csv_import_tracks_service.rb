class CsvImportTracksService
  include ApplicationHelper

  require 'csv'

  def initialize(file, season)
    @file = file
    @season = season
  end

  def call
    csv = CSV.parse(File.open(@file))

    tracks = []
    csv.drop(1).each do |row|
      next if row.empty?
      next if row.include?(nil)

      # If the track already exists in this season, reassign all its attributes except the name
      match = Track.find { |t| t.name.eql?(row[0]) && t.season_id.to_s.eql?(@season) }
      unless match.nil?
        match.update_attribute(:short_name, row[1])
        match.update_attribute(:difficulty, row[2])
        match.update_attribute(:length, row[3])
        match.update_attribute(:folder_name, row[4])
        match.update_attribute(:author, row[5])
        match.update_attribute(:stock, row[6])
        match.update_attribute(:average_lap_time, row[7])

        tracks << match
        next
      end

      track_hash = {
        :season => @season,
        :name => row[0],
        :short_name => row[1],
        :difficulty => row[2],
        :length => row[3],
        :folder_name => row[4],
        :author => row[5],
        :stock => row[6],
        :average_lap_time => row[7]
      }

      tracks << Track.new(track_hash)
    end

    tracks
  end

  # TODO: Check whether this csv corresponds to RVA track data
  def is_rva_track_data(_csv)
    true
  end
end

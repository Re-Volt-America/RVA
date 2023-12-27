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

      # Don't create duplicate tracks with the same name and season
      match = Track.find { |t| t.name.eql?(row[0]) && t.season_id.to_s.eql?(@season) }
      next unless match.nil?

      track_hash = {
        :season => @season,
        :name => row[0],
        :short_name => row[1],
        :difficulty => row[2],
        :length => row[3],
        :folder_name => row[4],
        :stock => row[5]
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

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
    csv.drop(1).each do |track|
      track_hash = {
        :season => @season,
        :name => track[0],
        :short_name => track[1],
        :difficulty => track[2],
        :length => track[3],
        :folder_name => track[4],
        :stock => track[5]
      }

      tracks << Track.new(track_hash)
    end

    tracks
  end

  # TODO: Check whether this csv corresponds to RVA track data
  def is_rva_track_data(csv)
    true
  end
end

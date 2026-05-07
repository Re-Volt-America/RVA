class CsvImportTracksService
  include ApplicationHelper

  require 'csv'

  def initialize(file, season)
    @file = file
    @season = season
  end

  def call
    csv = CSV.parse(read_csv_content)

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
        match.update_attribute(:lego, row[7])
        match.update_attribute(:average_lap_time, row[8])

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
        :lego => row[7],
        :average_lap_time => row[8]
      }

      tracks << Track.new(track_hash)
    end

    tracks
  end

  # TODO: Check whether this csv corresponds to RVA track data
  def is_rva_track_data(_csv)
    true
  end

  private

  def read_csv_content
    return @file.read if @file.respond_to?(:read)

    File.read(safe_csv_path(@file.to_s))
  end

  def safe_csv_path(file_name)
    base_name = File.basename(file_name)
    raise ArgumentError, 'Invalid CSV file name' unless base_name.match?(/\A[a-zA-Z0-9._-]+\.csv\z/)

    base_dir = Rails.root.join('tmp').to_s
    full_path = File.expand_path(File.join(base_dir, base_name))
    raise ArgumentError, 'Invalid CSV file path' unless full_path.start_with?(base_dir + File::SEPARATOR)

    full_path
  end
end

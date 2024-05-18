class CsvImportCarsService
  include ApplicationHelper

  require 'csv'

  def initialize(file, season, category)
    @file = file
    @season = season
    @category = category
  end

  def call
    csv = CSV.parse(File.open(@file))

    cars = []
    csv.drop(1).each do |row|
      next if row.empty?
      next if row.include?(nil)

      # If the car already exists in this season, reassign all its attributes except the name
      match = Car.find { |c| c.name.eql?(row[0]) && c.season_id.to_s.eql?(@season) }
      unless match.nil?
        match.update_attribute(:speed, row[1])
        match.update_attribute(:accel, row[2])
        match.update_attribute(:weight, row[3])
        match.update_attribute(:multiplier, row[4].to_f)
        match.update_attribute(:folder_name, row[5])
        match.update_attribute(:author, row[6])
        match.update_attribute(:stock, row[7])

        cars << match
        next
      end

      car_hash = {
        :season => @season,
        :category => @category,
        :name => row[0],
        :speed => row[1],
        :accel => row[2],
        :weight => row[3],
        :multiplier => row[4],
        :folder_name => row[5],
        :author => row[6],
        :stock => true?(row[7])
      }

      cars << Car.new(car_hash)
    end

    cars
  end

  # TODO: Check whether this csv corresponds to RVA car data
  def is_rva_car_data(_csv)
    true
  end
end

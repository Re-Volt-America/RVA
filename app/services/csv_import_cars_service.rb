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
    csv.drop(1).each do |car|
      # Don't create duplicate cars with the same name and season
      match = Car.find { |c| c.name.eql?(car[0]) && c.season_id.to_s.eql?(@season) }
      next unless match.nil?

      car_hash = {
        :season => @season,
        :category => @category,
        :name => car[0],
        :speed => car[1],
        :accel => car[2],
        :weight => car[3],
        :multiplier => car[4],
        :folder_name => car[5],
        :stock => true?(car[6])
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

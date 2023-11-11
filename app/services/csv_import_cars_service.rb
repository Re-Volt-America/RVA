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
  def is_rva_car_data(csv)
    true
  end
end

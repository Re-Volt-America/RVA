module CarsHelper
  # Filters out inactive cars.
  def cars_of_category(category, season = selected_season)
    if season.nil?
      Car.all.filter { |c| c.category == category && c.active? }
    else
      season.cars.filter { |c| c.category == category && c.active? }
    end
  end

  # @param category [Integer] Category number
  # @return [String] Path to the passed category, or nil if not found
  def car_category_path(category, season = nil)
    opts = season.nil? ? {} : { :season => season.id }

    case category
    when SYS::CATEGORY::ROOKIE
      cars_rookie_path(opts)
    when SYS::CATEGORY::AMATEUR
      cars_amateur_path(opts)
    when SYS::CATEGORY::ADVANCED
      cars_advanced_path(opts)
    when SYS::CATEGORY::SEMI_PRO
      cars_semipro_path(opts)
    when SYS::CATEGORY::PRO
      cars_pro_path(opts)
    when SYS::CATEGORY::SUPER_PRO
      cars_superpro_path(opts)
    when SYS::CATEGORY::CLOCKWORK
      cars_clockwork_path(opts)
    else
      cars_path(opts)
    end
  end

  def category_cache_key(category, season = nil)
    base = case category
           when SYS::CATEGORY::ROOKIE
             'rookie_cars'
           when SYS::CATEGORY::AMATEUR
             'amateur_cars'
           when SYS::CATEGORY::ADVANCED
             'advanced_cars'
           when SYS::CATEGORY::SEMI_PRO
             'semipro_cars'
           when SYS::CATEGORY::PRO
             'pro_cars'
           when SYS::CATEGORY::SUPER_PRO
             'superpro_cars'
           when SYS::CATEGORY::CLOCKWORK
             'clockwork_cars'
           else
             'unknown'
           end

    season.nil? ? base : "#{base}:#{season.id}"
  end
end

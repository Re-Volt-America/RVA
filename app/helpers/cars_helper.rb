module CarsHelper
  # @return [Array] All the cars of the passed category from the current season. If there is no current season, then
  # from all cars in the database.
  def cars_of_category(category)
    if current_season.nil?
      Car.all.filter { |c| c.category == category }
    else
      current_season.cars.filter { |c| c.category == category }
    end
  end

  # @param category [Integer] Category number
  # @return [String] Path to the passed category, or nil if not found
  def car_category_path(category)
    case category
    when SYS::CATEGORY::ROOKIE
      cars_rookie_path
    when SYS::CATEGORY::AMATEUR
      cars_amateur_path
    when SYS::CATEGORY::ADVANCED
      cars_advanced_path
    when SYS::CATEGORY::SEMI_PRO
      cars_semipro_path
    when SYS::CATEGORY::PRO
      cars_pro_path
    when SYS::CATEGORY::SUPER_PRO
      cars_superpro_path
    when SYS::CATEGORY::CLOCKWORK
      cars_clockwork_path
    else
      'unknown'
    end
  end

  def category_cache_key(category)
    case category
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
  end
end

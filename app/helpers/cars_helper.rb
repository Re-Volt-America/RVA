module CarsHelper
  # @return [Array] All the cars of the passed category
  def cars_of_category(category)
    Car.all.filter { |c| c.category == category }
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
end

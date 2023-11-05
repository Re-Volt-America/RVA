module CarsHelper
  def cars_of_category(category)
    Car.all.filter { |c| c.category == category }
  end
end

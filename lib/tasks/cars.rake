namespace :rva do
  desc "Set missing active flags to true for Car"
  task set_active_cars: :environment do
    puts "Setting active=true for Car where missing..."
    begin
      Car.where(:active.exists => false).update_all(active: true)
      puts "Cars updated."
    rescue => e
      puts "Error updating cars: #{e.message}"
      raise
    end
  end
end

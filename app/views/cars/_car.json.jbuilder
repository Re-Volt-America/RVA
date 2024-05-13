json.extract! car, :id, :name, :speed, :accel, :weight, :multiplier, :category, :author, :stock, :folder_name, :created_at,
              :updated_at
json.url car_url(car, :format => :json)

json.extract! car, :id, :name, :speed, :accel, :weight, :multiplier, :category, :folder_name, :author, :stock, :carbox_filename, :created_at,
              :updated_at
json.url car_url(car, :format => :json)

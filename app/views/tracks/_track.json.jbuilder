json.extract! track, :id, :name, :short_name, :difficulty, :length, :folder_name, :author, :stock, :lego, :average_lap_time, :active,
              :created_at, :updated_at
json.url track_url(track, :format => :json)

json.extract! track, :id, :name, :short_name, :difficulty, :length, :folder_name, :created_at, :updated_at
json.url track_url(track, format: :json)

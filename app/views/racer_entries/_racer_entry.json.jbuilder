json.extract! racer_entry, :id, :name, :car, :best_lap, :finished, :cheating, :team, :created_at, :updated_at
json.url racer_entry_url(racer_entry, format: :json)

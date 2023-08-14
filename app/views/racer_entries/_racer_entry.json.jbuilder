json.extract! racer_entry, :id, :username, :time, :best_lap, :finished, :cheating, :car
json.url racer_entry_url(racer_entry, :format => :json)

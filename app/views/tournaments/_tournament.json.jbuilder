json.extract! tournament, :id, :name, :date, :format, :created_at, :updated_at
json.url tournament_url(tournament, format: :json)

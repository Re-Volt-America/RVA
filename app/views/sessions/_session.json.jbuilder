json.extract! session, :id, :number, :host, :version, :physics, :protocol, :pickups, :date, :teams, :category, :ranking, :races, :created_at, :updated_at
json.url session_url(session, :format => :json)

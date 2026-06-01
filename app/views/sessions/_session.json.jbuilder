json.extract! session, :id, :number, :version, :physics, :protocol, :pickups, :date, :teams, :category,
              :ranking, :races, :created_at, :updated_at
json.host session.host_name
json.host_id session.host_id
json.url session_url(session, :format => :json)

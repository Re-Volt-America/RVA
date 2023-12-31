json.extract! team, :id, :name, :short_name, :color, :points, :leader, :created_at, :updated_at
json.url team_url(team, :format => :json)

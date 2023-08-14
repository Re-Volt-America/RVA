json.extract! stat, :id, :race_wins, :race_count, :average_position, :participation_rate, :official_score,
              :obtained_points, :team_points
json.url stat_url(stat, :format => :json)

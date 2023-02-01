json.extract! player_stat, :id, :race_wins, :race_count, :average_position, :participation_rate, :official_score, :obtained_points, :team_points, :created_at, :updated_at
json.url player_stat_url(player_stat, format: :json)

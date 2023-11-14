class UserStatsService
  include ApplicationHelper

  def add_stats(rva_results)
    count = 0
    rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      # NOTE: Only update stats for registered users
      unless row[3].is_a?(User)
        count += 1
        next
      end

      user = row[3]
      positions = row[4]
      race_wins = positions.count('1')
      positions_sum = positions.map(&:to_i).sum

      user.stats.race_wins += race_wins
      user.stats.race_count += row[7].to_i
      user.stats.positions_sum += positions_sum
      user.stats.session_count += 1
      user.stats.average_position = user.stats.positions_sum / user.stats.race_count
      user.stats.participation_rate = (user.stats.race_count / (user.stats.session_count * 20))
      user.stats.official_score += row[9].to_f
      user.stats.obtained_points += row[6].to_i

      user.save

      count += 1
    end
  end

  # Subtracts the given results from each racer's statistics
  def remove_stats(rva_results)
    count = 0
    rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      # NOTE: Only update stats for registered users
      unless row[3].is_a?(User)
        count += 1
        next
      end

      user = row[3]
      positions = row[4]
      race_wins = positions.count('1')
      positions_sum = positions.map(&:to_i).sum

      user.stats.race_wins -= race_wins
      user.stats.race_count -= row[7].to_i
      user.stats.positions_sum -= positions_sum
      user.stats.session_count -= 1
      user.stats.average_position = user.stats.positions_sum / user.stats.race_count
      user.stats.participation_rate = (user.stats.race_count / (user.stats.session_count * 20))
      user.stats.official_score -= row[9].to_f
      user.stats.obtained_points -= row[6].to_i

      user.save

      count += 1
    end
  end
end

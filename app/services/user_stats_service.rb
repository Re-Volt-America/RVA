class UserStatsService
  include ApplicationHelper

  def add_stats(rva_results)
    count = 0
    pos = 1
    rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      # NOTE: Only update stats for registered users
      unless row[3].is_a?(User)
        count += 1
        pos += 1
        next
      end

      user = row[3]
      positions = row[4]
      race_wins = positions.count('1')
      race_podiums = count_all(positions, %w[1 2 3])
      positions_sum = positions.map(&:to_i).sum

      user.stats.race_wins += race_wins
      user.stats.race_count += row[7].to_i
      user.stats.race_win_rate = (user.stats.race_wins / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.race_podiums += race_podiums

      user.stats.session_count += 1
      user.stats.session_wins += 1 if pos == 1
      user.stats.session_win_rate = (user.stats.session_wins / (user.stats.session_count.nonzero? || 1)).round(2)
      user.stats.session_podiums += 1 if pos <= 3

      user.stats.positions_sum += positions_sum
      user.stats.average_position = (user.stats.positions_sum.to_f / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.participation_rate = (user.stats.race_count / (user.stats.session_count * 20).nonzero? || 1).round(2)

      user.stats.official_score += row[9].to_f
      user.stats.obtained_points += row[6].to_i

      user.save

      count += 1
      pos += 1
    end
  end

  # Subtracts the given results from each racer's statistics
  def remove_stats(rva_results)
    count = 0
    pos = 1
    rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      # NOTE: Only update stats for registered users
      unless row[3].is_a?(User)
        count += 1
        pos += 1
        next
      end

      user = row[3]
      positions = row[4]
      race_wins = positions.count('1')
      race_podiums = count_all(positions, %w[1 2 3])
      positions_sum = positions.map(&:to_i).sum

      user.stats.race_wins -= race_wins
      user.stats.race_count -= row[7].to_i
      user.stats.race_win_rate = (user.stats.race_wins / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.race_podiums -= race_podiums

      user.stats.session_count -= 1
      user.stats.session_wins -= 1 if pos == 1
      user.stats.session_win_rate = (user.stats.session_wins / (user.stats.session_count.nonzero? || 1)).round(2)
      user.stats.session_podiums -= 1 if pos <= 3

      user.stats.positions_sum -= positions_sum
      user.stats.average_position = (user.stats.positions_sum.to_f / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.participation_rate = (user.stats.race_count / (user.stats.session_count * 20).nonzero? || 1).round(2)

      user.stats.official_score -= row[9].to_f
      user.stats.obtained_points -= row[6].to_i

      user.save

      count += 1
      pos += 1
    end
  end
end

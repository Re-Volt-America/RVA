class StatsService
  include ApplicationHelper

  def initialize(session, rva_results)
    @session = session
    @rva_results = rva_results
  end

  def add_stats
    add_user_stats
    add_session_stats
    add_ranking_stats
    add_season_stats
  end

  def remove_stats
    remove_user_stats
    remove_ranking_stats
    remove_season_stats
  end

  # Adds the given @rva_results to the @session itself
  def add_session_stats
    racer_result_entries = []
    num_entries = 0
    count = 0

    @rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      unless row[3].is_a?(User)
        count += 1
        next
      end

      user = row[3]
      positions = row[4]
      average_position = row[5].to_f
      positions_sum = positions.map(&:to_i).sum
      obtained_points = row[6].to_i
      official_score = row[9].to_f
      race_count = row[7].to_i
      participation_multiplier = row[8].to_f

      racer_result_entry_hash = {
        :username => user.username,
        :country => user.country,
        :race_count => race_count,
        :positions_sum => positions_sum,
        :average_position => average_position,
        :obtained_points => obtained_points,
        :official_score => official_score,
        :participation_multiplier => participation_multiplier,
        :team => nil # TODO: Extend support for team sessions
      }

      racer_result_entries << RacerResultEntry.new(racer_result_entry_hash)
      count += 1
      num_entries += 1
    end

    @session.racer_result_entries = racer_result_entries
    @session.update!
  end

  # Adds the given @rva_results to the ranking associated with @session
  def add_ranking_stats
    ranking = @session.ranking

    session_entries = @session.racer_result_entries
    ranking_entries = ranking.racer_result_entries

    session_entries.each do |session_entry|
      ranking_entry = ranking_entries.find { |e| e.username.eql?(session_entry.username) }

      if ranking_entry.nil?
        se_hash = {
          :username => session_entry.username,
          :country => session_entry.country,
          :race_count => session_entry.race_count,
          :session_count => 1,
          :positions_sum => session_entry.positions_sum,
          :average_position => session_entry.average_position,
          :obtained_points => session_entry.obtained_points,
          :official_score => session_entry.official_score,
          :participation_multiplier => session_entry.participation_multiplier,
          :team => session_entry.team
        }

        ranking_entries << RacerResultEntry.new(se_hash)
      else
        ranking_entry.country = session_entry.country
        ranking_entry.session_count += 1
        ranking_entry.race_count += session_entry.race_count
        ranking_entry.positions_sum += session_entry.positions_sum
        ranking_entry.average_position += (ranking_entry.positions_sum.to_f / (ranking_entry.race_count.nonzero? || 1)).round(2)
        ranking_entry.obtained_points += session_entry.obtained_points.to_i
        ranking_entry.official_score += session_entry.official_score.to_f
        ranking_entry.participation_multiplier = (ranking_entry.race_count.to_f / ((ranking_entry.session_count * 20).nonzero? || 1)).round(2)
      end
    end

    ranking.racer_result_entries = ranking_entries.sort_by { |e| e.official_score }.reverse!
    ranking.update!
  end

  # Adds the given @rva_results to the season associated with @session
  def add_season_stats
    season = @session.ranking.season

    session_entries = @session.racer_result_entries
    season_entries = season.racer_result_entries

    session_entries.each do |session_entry|
      season_entry = season_entries.find { |e| e.username.eql?(session_entry.username) }

      if season_entry.nil?
        session_entry_hash = {
          :username => session_entry.username,
          :country => session_entry.country,
          :session_count => 1,
          :race_count => session_entry.race_count,
          :positions_sum => session_entry.positions_sum,
          :average_position => session_entry.average_position,
          :obtained_points => session_entry.obtained_points,
          :official_score => session_entry.official_score,
          :participation_multiplier => session_entry.participation_multiplier,
          :team => session_entry.team
        }

        season_entries << RacerResultEntry.new(session_entry_hash)
      else
        season_entry.country = session_entry.country
        season_entry.session_count += 1
        season_entry.race_count += session_entry.race_count
        season_entry.positions_sum += session_entry.positions_sum
        season_entry.average_position += (season_entry.positions_sum.to_f / (season_entry.race_count.nonzero? || 1)).round(2)
        season_entry.obtained_points += session_entry.obtained_points.to_i
        season_entry.official_score += session_entry.official_score.to_f
        season_entry.participation_multiplier = (season_entry.race_count.to_f / ((season_entry.session_count * 20).nonzero? || 1)).round(2)
      end
    end

    season.racer_result_entries = season_entries.sort_by { |e| e.official_score }.reverse!
    season.update!
  end

  # Adds the given @rva_results to each user's statistics
  def add_user_stats
    count = 0
    pos = 1
    @rva_results.drop(1).each do |row|
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
      user.stats.race_win_rate = (user.stats.race_wins.to_f / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.race_podiums += race_podiums

      user.stats.session_count += 1
      user.stats.session_wins += 1 if pos == 1
      user.stats.session_win_rate = (user.stats.session_wins.to_f / (user.stats.session_count.nonzero? || 1)).round(2)
      user.stats.session_podiums += 1 if pos <= 3

      user.stats.positions_sum += positions_sum
      user.stats.average_position = (user.stats.positions_sum.to_f / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.participation_rate = (user.stats.race_count.to_f / ((user.stats.session_count * 20).nonzero? || 1)).round(2)

      user.stats.obtained_points += row[6].to_i
      user.stats.official_score += row[9].to_f

      user.save

      count += 1
      pos += 1
    end
  end

  def remove_ranking_stats
    ranking = @session.ranking
    ranking_entries = ranking.racer_result_entries

    ranking_entries.each do |ranking_entry|
      ranking_entry.country = ranking_entry.country
      ranking_entry.session_count -= 1
      ranking_entry.race_count -= ranking_entry.race_count
      ranking_entry.positions_sum -= ranking_entry.positions_sum
      ranking_entry.average_position -= (ranking_entry.positions_sum.to_f / (ranking_entry.race_count.nonzero? || 1)).round(2)
      ranking_entry.obtained_points -= ranking_entry.obtained_points.to_i
      ranking_entry.official_score -= ranking_entry.official_score.to_f
      ranking_entry.participation_multiplier = (ranking_entry.race_count.to_f / ((ranking_entry.session_count * 20).nonzero? || 1)).round(2)
    end

    ranking.racer_result_entries = ranking_entries.sort_by { |e| e.official_score }.reverse!
    ranking.update!
  end

  def remove_season_stats
    season = @session.ranking.season
    season_entries = season.racer_result_entries

    season_entries.each do |season_entry|
      season_entry.country = season_entry.country
      season_entry.session_count -= 1
      season_entry.race_count -= season_entry.race_count
      season_entry.positions_sum -= season_entry.positions_sum
      season_entry.average_position -= (season_entry.positions_sum.to_f / (season_entry.race_count.nonzero? || 1)).round(2)
      season_entry.obtained_points -= season_entry.obtained_points.to_i
      season_entry.official_score -= season_entry.official_score.to_f
      season_entry.participation_multiplier = (season_entry.race_count.to_f / ((season_entry.session_count * 20).nonzero? || 1)).round(2)
    end

    season.racer_result_entries = season_entries.sort_by { |e| e.official_score }.reverse!
    season.update!
  end

  # Subtracts the given results from each user's statistics
  def remove_user_stats
    count = 0
    pos = 1

    @rva_results.drop(1).each do |row|
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
      user.stats.race_win_rate = (user.stats.race_wins.to_f / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.race_podiums -= race_podiums

      user.stats.session_count -= 1
      user.stats.session_wins -= 1 if pos == 1
      user.stats.session_win_rate = (user.stats.session_wins.to_f / (user.stats.session_count.nonzero? || 1)).round(2)
      user.stats.session_podiums -= 1 if pos <= 3

      user.stats.positions_sum -= positions_sum
      user.stats.average_position = (user.stats.positions_sum.to_f / (user.stats.race_count.nonzero? || 1)).round(2)
      user.stats.participation_rate = (user.stats.race_count.to_f / ((user.stats.session_count * 20).nonzero? || 1)).round(2)

      user.stats.obtained_points -= row[6].to_i
      user.stats.official_score -= row[9].to_f

      user.update!

      count += 1
      pos += 1
    end
  end
end

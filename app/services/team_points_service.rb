class TeamPointsService
  include ApplicationHelper

  def initialize(session, rva_results)
    @session = session
    @rva_results = rva_results
  end

  def add_points
    add_team_points
    add_session_points
    add_ranking_points
    add_season_points
  end

  def remove_points
    remove_team_points
    remove_ranking_points
    remove_season_points
  end

  def add_session_points
    team_result_entries = []
    count = 0

    @rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      # Only go through with valid teams
      unless row[4].is_a?(Team)
        count += 1
        next
      end

      team = row[4]
      points = row[7].to_i # PA

      session_entry = team_result_entries.find { |e| e.name.eql?(team.name) }
      if session_entry.nil?
        team_result_entry_hash = {
          :name => team.name,
          :short_name => team.short_name,
          :team_logo_data => team.team_logo_data,
          :color => team.color,
          :points => points
        }

        team_result_entries << TeamResultEntry.new(team_result_entry_hash)
      else
        session_entry.points += points
      end

      count += 1
    end

    @session.team_result_entries = team_result_entries.sort_by(&:points).reverse!
    @session.update!
  end

  def add_ranking_points
    ranking = @session.ranking

    session_entries = @session.team_result_entries
    ranking_entries = ranking.team_result_entries

    session_entries.each do |session_entry|
      ranking_entry = ranking_entries.find { |e| e.name.eql?(session_entry.name) }

      if ranking_entry.nil?
        se_hash = {
          :name => session_entry.name,
          :short_name => session_entry.short_name,
          :team_logo_data => session_entry.team_logo_data,
          :color => session_entry.color,
          :points => session_entry.points
        }

        ranking_entries << TeamResultEntry.new(se_hash)
      else
        ranking_entry.points += session_entry.points
      end
    end

    ranking.team_result_entries = ranking_entries.sort_by(&:points).reverse!
    ranking.update!
  end

  def add_season_points
    season = @session.ranking.season

    session_entries = @session.team_result_entries
    season_entries = season.team_result_entries

    session_entries.each do |session_entry|
      season_entry = season_entries.find { |e| e.name.eql?(session_entry.name) }

      if season_entry.nil?
        session_entry_hash = {
          :name => session_entry.name,
          :short_name => session_entry.short_name,
          :team_logo_data => session_entry.team_logo_data,
          :color => session_entry.color,
          :points => session_entry.points
        }

        season_entries << TeamResultEntry.new(session_entry_hash)
      else
        season_entry.points += session_entry.points
      end
    end

    season.team_result_entries = season_entries.sort_by(&:points).reverse!
    season.update!
  end

  def add_team_points
    count = 0
    teams = []

    @rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      # Only go through with valid teams
      unless row[4].is_a?(Team)
        count += 1
        next
      end

      team = teams.find { |t| t.name.eql?(row[4].name) }
      if team.nil?
        team = Team.find { |t| t.name.eql?(row[4].name) }
        teams << team
      end

      team.points += row[7] # PA

      team.save

      count += 1
    end
  end

  def remove_ranking_points
    ranking = @session.ranking
    ranking_entries = ranking.team_result_entries
    empty_entries = []

    ranking_entries.each do |ranking_entry|
      session_entry = @session.team_result_entries.find { |e| e.name.eql?(ranking_entry.name) }
      next if session_entry.nil?

      ranking_entry.points -= session_entry.points

      empty_entries << ranking_entry if ranking_entry.points.zero?
    end

    # If a team has zero points, then it's not part of the ranking. We remove them all!
    ranking_entries -= empty_entries

    ranking.racer_result_entries = ranking_entries.sort_by(&:points).reverse!
    ranking.update!
  end

  def remove_season_points
    season = @session.ranking.season
    season_entries = season.racer_result_entries
    empty_entries = []

    season_entries.each do |season_entry|
      session_entry = @session.team_result_entries.find { |e| e.username.eql?(season_entry.username) }
      next if session_entry.nil?

      season_entry.points = session_entry.points

      empty_entries << season_entry if season_entry.points.zero?
    end

    # If a team has zero points, then it's not part of the ranking. We remove them all!
    season_entries -= empty_entries

    season.team_result_entries = season_entries.sort_by(&:points).reverse!
    season.update!
  end

  def remove_team_points
    count = 0
    teams = []

    @rva_results.drop(1).each do |row|
      if count.odd?
        count += 1
        next
      end

      # Only go through with valid teams
      unless row[4].is_a?(Team)
        count += 1
        next
      end

      team = teams.find { |t| t.name.eql?(row[4].name) }
      if team.nil?
        team = Team.find { |t| t.name.eql?(row[4].name) }
        teams << team
      end

      team.points -= row[7] # PA

      team.update!

      count -= 1
    end
  end
end

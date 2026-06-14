module SessionsHelper
  include RankingsHelper

  def latest_session
    nil if current_ranking.nil?

    current_ranking.sessions.last
  end

  def position_color(pos)
    case pos
    when '1'
      return SYS::FIRST_PLACE_COLOR
    when '2'
      return SYS::SECOND_PLACE_COLOR
    when '3'
      return SYS::THIRD_PLACE_COLOR
    else
      return SYS::INVALID_PLACE_COLOR if pos.start_with?("'")
    end

    ''
  end

  def singles_session_meta_desc(results_table)
    rows = results_table.rows.first(3)
    return '' if rows.empty?

    top1, top2, top3 = rows

    "#{pretty_datetime(results_table.session_date)}\n
    Top Score:
        1. #{top1&.racer_name} (#{top1&.official_score})
        2. #{top2&.racer_name} (#{top2&.official_score})
        3. #{top3&.racer_name} (#{top3&.official_score})"
  end

  def teams_session_meta_desc(results_table)
    rows = results_table.rows.first(3)
    return '' if rows.empty?

    top1, top2, top3 = rows

    "#{pretty_datetime(results_table.session_date)}\n
    Top Score:
        1. #{top1&.racer_name} (#{top1&.obtained_points})
        2. #{top2&.racer_name} (#{top2&.obtained_points})
        3. #{top3&.racer_name} (#{top3&.obtained_points})"
  end
end

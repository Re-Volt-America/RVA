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

  def singles_session_meta_desc(rva_results)
    top1 = rva_results[1][3].is_a?(User) ? rva_results[1][3].username : rva_results[1][3]
    top2 = rva_results[3][3].is_a?(User) ? rva_results[3][3].username : rva_results[3][3]
    top3 = rva_results[5][3].is_a?(User) ? rva_results[5][3].username : rva_results[5][3]

    "#{pretty_datetime(rva_results[1][1])}\n
    Top Score:
        1. #{top1} (#{rva_results[1][9]})
        2. #{top2} (#{rva_results[3][9]})
        3. #{top3} (#{rva_results[5][9]})"
  end

  def teams_session_meta_desc(rva_results)
    top1 = rva_results[1][3].is_a?(User) ? rva_results[1][3].username : rva_results[1][3]
    top2 = rva_results[3][3].is_a?(User) ? rva_results[3][3].username : rva_results[3][3]
    top3 = rva_results[5][3].is_a?(User) ? rva_results[5][3].username : rva_results[5][3]

    "#{pretty_datetime(rva_results[1][1])}\n
    Top Score:
        1. #{top1} (#{rva_results[1][7]})
        2. #{top2} (#{rva_results[3][7]})
        3. #{top3} (#{rva_results[5][7]})"
  end
end

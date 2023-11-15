class StatsController < ApplicationController
  def index
    params[:sort] ||= 'race_wins'

    @users = User.all.sort_by { |u| u.stats.read_attribute(params[:sort]) }
    # FIXME: Zero values of average_position should be ignored when sorting...
    # TODO: Maybe add username search?
    @users.reverse! # unless params[:sort].eql?('average_position')


    @users = Kaminari.paginate_array(@users).page(params[:page]).per(20)

    @count = (@users.current_page - 1) * @users.limit_value + 1
    @sorts = {
      race_wins: 'Wins',
      race_podiums: 'Podiums',
      race_win_rate: 'Win Ratio',
      # average_position: 'Average Position',
      obtained_points: "Obtained Points",
      official_score: "Official Score"
    }
  end
end

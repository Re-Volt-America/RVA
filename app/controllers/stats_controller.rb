class StatsController < ApplicationController
  def index
    params[:sort] ||= 'race_wins'

    @users = User.all.sort_by { |u| u.stats.read_attribute(params[:sort]) }
    # FIXME: Zero values of average_position should be ignored when sorting...
    # TODO: Maybe add username search?
    @users.reverse! # unless params[:sort].eql?('average_position')
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(16)

    @count = ((@users.current_page - 1) * @users.limit_value) + 1
    @sorts = {
      :race_wins => I18n.t('rankings.stats.table.wins'),
      :race_podiums => I18n.t('rankings.stats.table.podiums'),
      :race_win_rate => I18n.t('rankings.stats.table.win-ratio'),
      # average_position: I18n.t("rankings.stats.table.average-pos"),
      :obtained_points => I18n.t('rankings.stats.table.obtained-points'),
      :official_score => I18n.t('rankings.stats.table.official-score')
    }
  end
end

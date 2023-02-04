class UsersController < ApplicationController
  before_action :authenticate_user!, :except => [:show]

  def members
    @users = User.all
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(20)
    @count = (@users.current_page - 1) * (@users.limit_value + 1)
  end

  def show
    @user = User.find_by!(:name => params[:name])
  end

  def new
    @user = User.new
    @user.build_profile
    @user.build_player_stat
  end

  def stats
  end
end

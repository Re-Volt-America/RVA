class UsersController < ApplicationController
  before_action :authenticate_user!, :except => [:show]

  def members
    @users = User.all
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(20)
    @count = (@users.current_page - 1) * (@users.limit_value + 1)
  end

  def show
    @user = User.find_by!(:username => params[:username])
  end

  def new
    @user = User.new
    @user.build_profile
    @user.build_stats
  end

  def stats
  end
end

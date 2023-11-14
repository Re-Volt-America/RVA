class UsersController < ApplicationController
  include ProfilesHelper

  before_action :authenticate_user!, :except => [:show, :stats]
  before_action :authenticate_admin, :only => [:new, :import]

  def members
    @users = User.all
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(20)
    @count = (@users.current_page - 1) * (@users.limit_value + 1)
  end

  def show
    @user = User.find_by!(:username => params[:username])

    # TODO: Find player position in current season/ranking
    # @ranking
  end

  def new
    @user = User.new
    @user.build_profile
    @user.build_stats
  end

  def import
    require 'csv_import_users_service'

    file = params[:file]
    if file.nil?
      respond_to do |format|
        format.html { redirect_to users_new_path, :notice => 'You must select a CSV file.' }
        format.json { render :json => 'You must select a CSV file.', :status => :bad_request, :layout => false }
      end

      return
    end

    if file.content_type != SYS::CSV_TYPE
      respond_to do |format|
        format.html { redirect_to users_new_path, :note => 'You may only upload CSV files.' }
        format.json { render :json => 'You may only upload CSV files.', :status => :bad_request, :layout => false }
      end

      return
    end

    @users = CsvImportUsersService.new(file).call

    respond_to do |format|
      @users.each do |user|
        if user.save!
          format.html { redirect_to root_path, :notice => 'Users successfully imported.' }
          format.json { render :show, :status => :created, :location => user, :layout => false }
        else
          format.html { render :new, :status => :unprocessable_entity }
          format.json { render :json => user.errors, :status => :unprocessable_entity, :layout => false }
        end
      end
    end
  end

  def stats; end
end

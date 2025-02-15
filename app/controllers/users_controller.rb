class UsersController < ApplicationController
  include ProfilesHelper
  include RankingsHelper

  before_action :authenticate_user!, :except => [:show, :stats]
  before_action :authenticate_admin, :except => [:show, :stats, :update_locale, :edit, :members]
  before_action :authenticate_mod, :only => [:edit, :members]

  def members
    @users = User.all.order(created_at: :desc)
    @users = Kaminari.paginate_array(@users.to_a).page(params[:page]).per(20)
    @count = (@users.current_page - 1) * @users.limit_value
  end

  def show
    @user = User.find_by!(:username => params[:username].upcase)
    @recent_sessions = []

    Session.all.each do |session|
      next unless session.racer_result_entries.any? { |r| r.username.upcase.eql?(params[:username].upcase) }

      @recent_sessions << session
    end

    @recent_sessions = @recent_sessions.last(5).reverse!

    @rank = if current_ranking
              current_ranking.get_rank(@user)
            else
              '-'
            end
  end

  # NOTE: This may be a bit hacky, but it gets the job done...
  def edit
    return if params[:username].nil?

    user = User.find { |u| u.username.downcase.eql?(params[:username].downcase) }

    return if user.nil?

    user_attr_names = []
    user.attributes.each do |el|
      user_attr_names << el[0]
    end

    profile_attr_names = []
    user.profile.attributes.each do |el|
      profile_attr_names << el[0]
    end

    # Update user attributes
    user_attr_names.each do |attr|
      next if params[:user][attr].nil?

      # FIXME: When users don't have a team_id attr, this fails to update their team
      if attr.eql?('team_id')
        team = Team.all.find { |t| t.leader.id.eql?(user.id) }

        # If user is team leader, we cannot move them to a different team ... we abort
        if !team.nil? && !team.id.to_s.eql?(params[:user][attr])
          respond_to do |format|
            format.html do
              redirect_to user_path(user),
                          :notice => t('.controller.update.leader', :user => user.username, :team => team.name)
            end
          end and return
        end
      end

      user[attr] = params[:user][attr]
    end

    # Update user.profile attributes
    profile_attr_names.each do |attr|
      next if params[:user][:profile_attributes][attr].nil?

      user.profile[attr] = params[:user][:profile_attributes][attr]
    end

    respond_to do |format|
      if user.update!
        format.html { redirect_to user_path(user), :notice => t('.controller.update.success') }
      else
        format.html { redirect_to user_path(user), :status => :unprocessable_entity }
      end
    end
  end

  def update_locale
    return if !user_signed_in? || params[:locale].nil?

    current_user.locale = params[:locale]
    current_user.update!

    respond_to do |format|
      if current_user.update!
        format.html do
          redirect_back :fallback_location => root_path,
                        :notice => t('.controller.update.locale',
                                     :lang => SYS::LOCALES_MAP.key(params[:locale].to_sym))
        end
      else
        format.html { redirect_to root_path, :status => :unprocessable_entity }
      end
    end
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
        format.html { redirect_to users_new_path, :notice => t('misc.controller.import.select') }
        format.json { render :json => t('misc.controller.import.select'), :status => :bad_request, :layout => false }
      end and return
    end

    unless SYS::CSV_TYPES.include?(file.content_type)
      respond_to do |format|
        format.html { redirect_to users_new_path, :notice => t('misc.controller.import.upload') }
        format.json { render :json => t('misc.controller.import.upload'), :status => :bad_request, :layout => false }
      end and return
    end

    @users = CsvImportUsersService.new(file).call

    respond_to do |format|
      if @users.empty?
        format.html { redirect_to users_new_path, :notice => t('.controller.import.exists') }
        format.json { render :show, :status => :ok, :layout => false }
      end and return

      @users.each do |user|
        if user.save
          format.html { redirect_to root_path, :notice => t('.controller.import.success') }
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

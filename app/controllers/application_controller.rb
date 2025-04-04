class ApplicationController < ActionController::Base
  include ApplicationHelper
  include RankingsHelper

  before_action :set_locale
  before_action :build_navigation

  def set_locale
    if user_signed_in?
      I18n.locale = current_user.locale
      return
    end

    # If user is guest, we try to determine their locale ...

    locale = params[:locale] || locale_from_header

    I18n.locale = if !locale.nil? && SYS::LOCALES_MAP.values.include?(locale.to_sym)
                    locale
                  else
                    I18n.default_locale
                  end
  end

  def default_url_options
    return { :locale => I18n.locale } unless user_signed_in?

    {}
  end

  # Detect Browser's locale and use that by default
  def locale_from_header
    request.env.fetch('HTTP_ACCEPT_LANGUAGE', '').scan(/[a-z]{2}/).first
  end

  def build_navigation
    return unless user_signed_in?

    @admin_nav = [
      { :name => t('nav.user.admin.upload-session'), :path => new_session_path, :organizer => true },
      { :name => t('nav.user.admin.generate-tracklist'), :path => weekly_schedules_path, :organizer => true },
      { :name => "Administrate Users", :path => admin_users_path  },
      { :name => t('nav.user.admin.create-season'), :path => new_season_path },
      { :name => t('nav.user.admin.import-tracks'), :path => new_track_path },
      { :name => t('nav.user.admin.import-cars'), :path => new_car_path },
      # { :name => t('nav.user.admin.new-team'), :path => new_team_path },
      # { :name => t('nav.user.admin.new-tournament'), :path => new_tournament_path },
      { :name => t('nav.user.admin.import-users'), :path => users_new_path }
    ]
    @nav = [
      { :name => t('nav.user.admin.title'), :path => '', :sub => @admin_nav, :organizer => true },
      { :name => t('nav.user.my-profile'), :path => user_path(current_user.username), :user => true },
      { :name => t('nav.user.settings'), :path => main_app.edit_user_registration_path, :user => true }
    ]
  end

  def nav_path(item)
    item[:path] || main_app.routes.url_helpers.url_for(
      :only_path => true,
      :controller => nav_controller(item).controller_path,
      :action => nav_action(item)
    )
  end

  def nav_link(item)
    %(<a class="dropdown-item" href="#{nav_path(item)}">#{item[:name]}</a>).html_safe
  end

  def render_navigation(item)
    if item[:sub]
      subs = item[:sub].map do |sub|
        if sub[:user] || user_is_admin? || ((sub[:organizer] && user_is_organizer?) || (sub[:mod] && user_is_mod?))
          render_navigation(sub)
        end
      end

      if item[:user] || user_is_admin? || ((item[:organizer] && user_is_organizer?) || (item[:mod] && user_is_mod?))
        %(
            <li class="dropdown-submenu">
                <a class="dropdown-item dropdown-toggle" href="#">#{item[:name]}</a>
                <ul class="dropdown-menu">
                    #{subs.join}
                </ul>
            </li>
          ).html_safe
      end
    elsif item[:user] || user_is_admin? || ((item[:organizer] && user_is_organizer?) || (item[:mod] && user_is_mod?))
      %(<li>#{nav_link(item)}</li>).html_safe
    end
  end

  helper_method :render_navigation

  def index
    @current_ranking = Rails.cache.fetch('current_ranking', :expires_in => 1.day) do
      current_ranking
    end

    if @current_ranking.nil?
      @recent_sessions = []
      return
    end

    @current_sessions = Rails.cache.fetch('current_sessions', :expires_in => 1.day) do
      current_ranking.sessions
    end

    @recent_sessions = Rails.cache.fetch('recent_sessions', :expires_in => 1.day) do
      @current_sessions.last(5).reverse!
    end
  end

  def authenticate_admin
    redirect_to root_path, :notice => t('alerts.no-permission') unless user_is_admin?
  end

  def authenticate_mod
    redirect_to root_path, :notice => t('alerts.no-permission') unless user_is_mod? || user_is_admin?
  end

  def authenticate_organizer
    redirect_to root_path, :notice => t('alerts.no-permission') unless user_is_organizer? || user_is_admin?
  end

  def authenticate_staff
    redirect_to root_path, :notice => t('alerts.no-permission') unless user_is_staff?
  end
end

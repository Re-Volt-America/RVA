class ApplicationController < ActionController::Base
  include ApplicationHelper
  include RankingsHelper

  before_action :build_navigation

  def build_navigation
    return unless user_signed_in?

    @admin_nav = [
      { :name => 'Upload Session', :path => new_session_path },
      { :name => 'Create Season', :path => new_season_path },
      { :name => 'Import Tracks', :path => new_track_path },
      { :name => 'Import Cars', :path => new_car_path },
      #{ :name => 'New Team', :path => new_team_path },
      #{ :name => 'New Tournament', :path => new_tournament_path },
      { :name => 'Import Users', :path => users_new_path }
    ]
    @nav = [
      { :name => 'Admin', :path => '', :sub => @admin_nav, :admin => true },
      { :name => 'Profile', :path => user_path(current_user.username) },
      { :name => 'Account', :path => main_app.edit_user_registration_path }
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
      return if item[:admin] && !user_is_admin?

      subs = item[:sub].map { |sub| render_navigation(sub) }.compact
      %(
          <li class="dropdown-submenu">
              <a class="dropdown-item dropdown-toggle" href="#">#{item[:name]}</a>
              <ul class="dropdown-menu">
                  #{subs.join}
              </ul>
          </li>
        ).html_safe
    else
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
    redirect_to root_path, :notice => 'You do not have permission' unless user_is_admin?
  end

  def authenticate_mod
    redirect_to root_path, :notice => 'You do not have permission' unless user_is_mod?
  end

  def authenticate_organizer
    redirect_to root_path, :notice => 'You do not have permission' unless user_is_organizer?
  end

  def authenticate_staff
    redirect_to root_path, :notice => 'You do not have permission' unless user_is_staff?
  end
end

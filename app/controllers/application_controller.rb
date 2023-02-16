class ApplicationController < ActionController::Base
  include ApplicationHelper

  before_action :build_navigation

  def build_navigation
    if user_signed_in?
      @nav = [
          { :name => "Profile", :path => user_path(current_user.name) },
          { :name => "New Session", :path => new_session_path },
          { :name => "Account", :path => main_app.edit_user_registration_path }
      ]
    end
  end

  def nav_path(item)
    item[:path] || main_app.routes.url_helpers.url_for(
        only_path: true,
        controller: nav_controller(item).controller_path,
        action: nav_action(item)
    )
  end

  def nav_link(item)
    %{<a class="dropdown-item" href="#{nav_path(item)}">#{item[:name]}</a>}.html_safe
  end

  def render_navigation(item)
    if item[:sub]
      #- TODO: Add sub-nav support
    else
      %{<li>#{nav_link(item)}</li>}.html_safe
    end
  end

  helper_method :render_navigation

  def index; end
end

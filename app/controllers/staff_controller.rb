class StaffController < ApplicationController
  def index
    @users = User.all

    @admins = @users.select(&:admin?)
    @mods = @users.select(&:mod?)
    @organizers = @users.select(&:organizer?)
  end
end

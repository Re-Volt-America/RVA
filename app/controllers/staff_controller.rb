class StaffController < ApplicationController
  def index
    @users = User.all

    @admins = @users.select(&:admin?)
    @developers = @users.select(&:developer?)
    @mods = @users.select(&:mod?)
    @organizers = @users.select(&:organizer?)
  end
end

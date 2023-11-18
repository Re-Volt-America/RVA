class StaffController < ApplicationController
  def index
    @users = User.all

    @admins = @users.select { |u| u.admin? }
    @mods = @users.select { |u| u.mod? }
    @organizers = @users.select { |u| u.organizer? }
  end
end

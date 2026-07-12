module Admin
  # Shared base for every Administration Panel controller. Restricts the whole
  # /admin section to signed-in administrators.
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin
  end
end

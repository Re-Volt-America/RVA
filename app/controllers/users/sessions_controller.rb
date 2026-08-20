class Users::SessionsController < Devise::SessionsController
  protected

  # Devise's default auth_options include a recall to sessions#new on failure.
  # In this app that recall is executed as POST and can trip CSRF verification.
  # Returning only scope/locale keeps failure flow on normal redirect behavior.
  def auth_options
    { :scope => resource_name, :locale => I18n.locale }
  end
end# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end

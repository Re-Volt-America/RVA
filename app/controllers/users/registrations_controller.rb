# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    prepend_before_action :check_captcha, :only => [:create]
    before_action :configure_sign_up_params, :only => [:create]
    before_action :configure_account_update_params, :only => [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    def check_captcha
      return if verify_recaptcha

      self.resource = resource_class.new sign_up_params
      resource.validate
      set_minimum_password_length
      respond_with_navigational(resource) { render :new }
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, :keys => [:username])
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, :keys => [
                                          :admin, :mod, :organizer, :sponsor, :locale, :country, :team,
                                          { :profile_attributes => [:id, :about, :gender, :public_email, :location, :discord, :github, :instagram, :crowdin, :steam, :twitter, :occupation, :interests, :profile_picture, :profile_picture_data],
                                            :stats_attributes => [:id, :race_wins, :race_win_rate, :race_podiums, :race_count, :positions_sum,
                                                                  :session_wins, :session_podiums, :session_win_rate, :session_count, :average_position, :participation_rate, :official_score, :obtained_points] }
                                        ])
    end

    def after_update_path_for(resource)
      super
      user_path(resource)
    end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end

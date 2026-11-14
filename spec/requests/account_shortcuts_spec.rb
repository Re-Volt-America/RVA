require 'rails_helper'

# Shor t addresses for the sign up, account and confirmation pages.
RSpec.describe 'Account shortcut pages', :type => :request do
  after(:each) do
    User.delete_all
  end

  it 'shows the sign up page at /register' do
    get '/register'
    expect(response).to be_successful
  end

  it 'shows the resend confirmation page at /confirm' do
    get '/confirm'
    expect(response).to be_successful
  end

  it 'sends a signed out visitor from /account to the sign in page' do
    get '/account'
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'shows the account page at /account when signed in' do
    sign_in create(:user)
    get '/account'
    expect(response).to be_successful
  end
end

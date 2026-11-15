require 'rails_helper'

RSpec.describe '/tournaments', :type => :request do
  after(:each) do
    Tournament.delete_all
    User.delete_all
  end

  let(:tournament_params) do
    { :tournament => { :name => 'Test Cup', :date => '2026-03-01', :format => 'Single race' } }
  end

  describe 'GET /new' do
    it 'sends a signed out visitor to the sign in page' do
      get new_tournament_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'shows the page to an admin' do
      sign_in create(:user, :admin => true)
      get new_tournament_path
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    it 'does not let a signed out visitor create a tournament' do
      expect { post tournaments_path, :params => tournament_params }.not_to change(Tournament, :count)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'does not let a regular user create a tournament' do
      sign_in create(:user)
      expect { post tournaments_path, :params => tournament_params }.not_to change(Tournament, :count)
      expect(response).to redirect_to(root_path)
    end
  end
end

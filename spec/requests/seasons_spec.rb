require 'rails_helper'

RSpec.describe '/seasons', :type => :request do
  after(:each) do
    Ranking.delete_all
    Season.delete_all
    User.delete_all
  end

  let(:season_params) do
    { :season => { :name => 'Season 99', :start_date => '2026-01-01', :end_date => '2026-06-30' } }
  end

  describe 'GET /new' do
    it 'sends a signed out visitor to the sign in page' do
      get new_season_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'shows the page to an admin' do
      sign_in create(:user, :admin => true)
      get new_season_path
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    it 'does not let a signed out visitor create a season' do
      expect { post seasons_path, :params => season_params }.not_to change(Season, :count)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'does not let a regular user create a season' do
      sign_in create(:user)
      expect { post seasons_path, :params => season_params }.not_to change(Season, :count)
      expect(response).to redirect_to(root_path)
    end

    it 'lets an admin create a season' do
      sign_in create(:user, :admin => true)
      expect { post seasons_path, :params => season_params }.to change(Season, :count).by(1)
    end
  end
end

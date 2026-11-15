require 'rails_helper'

RSpec.describe '/rankings', :type => :request do
  let(:season) { create(:season) }
  let(:ranking_params) { { :ranking => { :number => 99, :season => season.id.to_s } } }

  after(:each) do
    Ranking.delete_all
    Season.delete_all
    User.delete_all
  end

  describe 'POST /create' do
    it 'does not let a signed out visitor create a ranking' do
      expect { post rankings_path, :params => ranking_params }.not_to change(Ranking, :count)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'does not let a regular user create a ranking' do
      sign_in create(:user)
      expect { post rankings_path, :params => ranking_params }.not_to change(Ranking, :count)
      expect(response).to redirect_to(root_path)
    end

    it 'lets an admin create a ranking' do
      sign_in create(:user, :admin => true)
      expect { post rankings_path, :params => ranking_params }.to change(Ranking, :count).by(1)
    end
  end
end

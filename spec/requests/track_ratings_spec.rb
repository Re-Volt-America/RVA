require 'rails_helper'

RSpec.describe '/tracks/:track_id/rating', :type => :request do
  let(:track) { create(:track) }
  let(:user) { create(:user) }

  let(:valid_attributes) do
    { :gameplay_rating => 5, :visuals_rating => 3, :audio_rating => 4, :fun_rating => 5 }
  end

  after(:each) do
    TrackRating.delete_all
    Track.delete_all
    Season.delete_all
    User.delete_all
  end

  describe 'POST /create' do
    context 'when signed out' do
      it 'redirects to the sign in page' do
        post track_rating_path(track), :params => { :track_rating => valid_attributes }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in' do
      before { sign_in user }

      it 'creates a new rating for the track' do
        expect do
          post track_rating_path(track), :params => { :track_rating => valid_attributes }, :as => :turbo_stream
        end.to change(TrackRating, :count).by(1)

        expect(response).to have_http_status(:ok)

        rating = TrackRating.where(:track => track, :user => user).first
        expect(rating.gameplay_rating).to eq(5)
      end

      it 'updates the existing rating instead of creating a duplicate' do
        post track_rating_path(track), :params => { :track_rating => valid_attributes }, :as => :turbo_stream

        expect do
          post track_rating_path(track),
               :params => { :track_rating => valid_attributes.merge(:fun_rating => 1) },
               :as => :turbo_stream
        end.not_to change(TrackRating, :count)

        rating = TrackRating.where(:track => track, :user => user).first
        expect(rating.fun_rating).to eq(1)
      end

      it 'does not save an incomplete rating' do
        expect do
          post track_rating_path(track),
               :params => { :track_rating => valid_attributes.merge(:fun_rating => nil) },
               :as => :turbo_stream
        end.not_to change(TrackRating, :count)
      end

      it 'only reveals the display rating on the track after the vote threshold is met' do
        post track_rating_path(track), :params => { :track_rating => valid_attributes }, :as => :turbo_stream
        expect(Track.find(track.id).display_rating).to be_nil

        sign_in create(:user)
        post track_rating_path(track), :params => { :track_rating => valid_attributes }, :as => :turbo_stream
        # average_rating = (5 + 3 + 4 + 5) / 4 = 4.25 -> rounds to the nearest half-star, 4.5
        expect(Track.find(track.id).display_rating).to eq(4.5)
      end
    end
  end
end

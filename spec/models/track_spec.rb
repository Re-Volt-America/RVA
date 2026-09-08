require 'rails_helper'

RSpec.describe Track, :type => :model do
  after(:each) do
    TrackRating.delete_all
    Track.delete_all
    Season.delete_all
    User.delete_all
  end

  describe '#rating_count, #average_rating and #display_rating' do
    it 'has no ratings and no display rating by default' do
      track = create(:track)

      expect(track.rating_count).to eq(0)
      expect(track.average_rating).to be_nil
      expect(track.display_rating).to be_nil
    end

    it 'still hides the rating after a single vote' do
      track = create(:track)
      create(:track_rating, :track => track, :user => create(:user),
                            :gameplay_rating => 5, :visuals_rating => 5, :audio_rating => 5, :fun_rating => 5)

      track = Track.find(track.id)
      expect(track.rating_count).to eq(1)
      expect(track.display_rating).to be_nil
    end

    it 'reveals the rating, rounded to the nearest half-star, once the vote threshold is met' do
      track = create(:track)
      create(:track_rating, :track => track, :user => create(:user),
                            :gameplay_rating => 5, :visuals_rating => 5, :audio_rating => 5, :fun_rating => 5)
      create(:track_rating, :track => track, :user => create(:user),
                            :gameplay_rating => 4, :visuals_rating => 4, :audio_rating => 4, :fun_rating => 4)

      track = Track.find(track.id)
      expect(track.rating_count).to eq(2)
      expect(track.average_rating).to eq(4.5)
      expect(track.display_rating).to eq(4.5)
    end

    it 'rounds the average to the nearest half-star rather than the nearest whole star' do
      track = create(:track)
      create(:track_rating, :track => track, :user => create(:user),
                            :gameplay_rating => 5, :visuals_rating => 5, :audio_rating => 4, :fun_rating => 4)
      create(:track_rating, :track => track, :user => create(:user),
                            :gameplay_rating => 3, :visuals_rating => 3, :audio_rating => 2, :fun_rating => 3)

      track = Track.find(track.id)
      # (4.5 + 2.75) / 2 = 3.625 -> rounds to the nearest half-star, 3.5
      expect(track.average_rating).to eq(3.625)
      expect(track.display_rating).to eq(3.5)
    end

    it 'never displays below 1 or above 5 stars' do
      track = create(:track)
      create(:track_rating, :track => track, :user => create(:user),
                            :gameplay_rating => 1, :visuals_rating => 1, :audio_rating => 1, :fun_rating => 1)
      create(:track_rating, :track => track, :user => create(:user),
                            :gameplay_rating => 1, :visuals_rating => 1, :audio_rating => 1, :fun_rating => 1)

      track = Track.find(track.id)
      expect(track.display_rating).to eq(1)
    end

    it 'carries ratings over from the most recent previous season track with the same name' do
      previous_season = create(:season, :name => 'Season 1', :start_date => Date.new(2025, 1, 1), :current => false)
      current_season = create(:season, :name => 'Season 2', :start_date => Date.new(2026, 1, 1), :current => true)
      previous_track = create(:track, :season => previous_season, :name => 'Airport 1')

      previous_rating_one_attributes = {
        :track => previous_track,
        :user => create(:user),
        :gameplay_rating => 5,
        :visuals_rating => 4,
        :audio_rating => 3,
        :fun_rating => 4
      }
      previous_rating_two_attributes = {
        :track => previous_track,
        :user => create(:user),
        :gameplay_rating => 2,
        :visuals_rating => 2,
        :audio_rating => 3,
        :fun_rating => 2
      }

      previous_rating_one = create(:track_rating, previous_rating_one_attributes)
      previous_rating_two = create(:track_rating, previous_rating_two_attributes)

      current_track = create(:track, :season => current_season, :name => 'Airport 1')

      expect { current_track.carry_over_ratings_from_previous_season! }.to change(TrackRating, :count).by(2)

      current_track = Track.find(current_track.id)
      expect(current_track.rating_count).to eq(2)
      expect(current_track.display_rating).to eq(3.0)
      expect(current_track.track_ratings.map(&:user_id)).to match_array([previous_rating_one.user_id,
                                                                         previous_rating_two.user_id])
    end
  end
end

require 'rails_helper'

RSpec.describe TrackRating, :type => :model do
  after(:each) do
    TrackRating.delete_all
    Track.delete_all
    Season.delete_all
    User.delete_all
  end

  describe '#average_score' do
    it 'returns 5.0 when every category is rated 5 stars' do
      rating = build(:track_rating, :gameplay_rating => 5, :visuals_rating => 5, :audio_rating => 5,
                                    :fun_rating => 5)

      expect(rating.average_score).to eq(5.0)
    end

    it 'returns 1.0 when every category is rated 1 star' do
      rating = build(:track_rating, :gameplay_rating => 1, :visuals_rating => 1, :audio_rating => 1,
                                    :fun_rating => 1)

      expect(rating.average_score).to eq(1.0)
    end

    it 'weighs the Gameplay, Visuals, Audio and Fun categories equally' do
      rating = build(:track_rating, :gameplay_rating => 5, :visuals_rating => 1, :audio_rating => 3,
                                    :fun_rating => 5)

      # (5 + 1 + 3 + 5) / 4 = 3.5
      expect(rating.average_score).to eq(3.5)
    end
  end

  describe 'validations' do
    it 'is invalid without one of the required rating fields' do
      rating = build(:track_rating, :gameplay_rating => nil)

      expect(rating).not_to be_valid
      expect(rating.errors[:gameplay_rating]).not_to be_empty
    end

    it 'is invalid when a rating field is out of the 1-5 range' do
      rating = build(:track_rating, :fun_rating => 6)

      expect(rating).not_to be_valid
      expect(rating.errors[:fun_rating]).not_to be_empty
    end

    it 'only allows one rating per user per track' do
      track = create(:track)
      user = create(:user)
      create(:track_rating, :track => track, :user => user)

      duplicate = build(:track_rating, :track => track, :user => user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).not_to be_empty
    end

    it 'allows the same user to rate different tracks' do
      user = create(:user)
      create(:track_rating, :track => create(:track), :user => user)

      other = build(:track_rating, :track => create(:track), :user => user)

      expect(other).to be_valid
    end
  end
end

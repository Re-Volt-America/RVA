require 'rails_helper'

RSpec.describe TrophyService, :type => :service do
  after(:each) do
    Notification.delete_all
    User.delete_all
  end

  describe '.sync' do
    it 'awards every threshold trophy the user newly qualifies for' do
      user = create(:user)
      user.stats.session_wins = 10
      user.save!

      awarded = TrophyService.sync(user)
      keys = awarded.map { |t| t.key }

      expect(keys).to include(:first_win, :session_wins_10)
      expect(keys).not_to include(:session_wins_100)
      expect(user.reload.has_trophy?(:session_wins_10)).to be(true)
    end

    it 'creates a notification for each newly-awarded trophy' do
      user = create(:user)
      user.stats.session_wins = 1
      user.save!

      expect { TrophyService.sync(user) }
        .to change { Notification.where(:user_id => user.id, :kind => 'trophy').count }.by(1)
    end

    it 'is idempotent: running twice awards nothing the second time' do
      user = create(:user)
      user.stats.session_wins = 10
      user.save!

      TrophyService.sync(user)
      expect(TrophyService.sync(user)).to eq([])
    end
  end
end

require 'rails_helper'

RSpec.describe Trophy, :type => :model do
  # The registry is global; snapshot and restore it so these tests don't clobber
  # the real trophy definitions loaded from config/initializers/trophies.rb.
  around(:each) do |example|
    saved = Trophy.registry.dup
    Trophy.reset!
    example.run
    Trophy.reset!
    saved.each { |k, v| Trophy.registry[k] = v }
  end

  describe '.define' do
    it 'registers a declarative threshold trophy earned when the stat is met' do
      Trophy.define :win_five, :icon => 'fa-medal', :tier => :silver,
                    :stat => :session_wins, :at_least => 5

      trophy = Trophy.find(:win_five)
      expect(trophy).to be_present
      expect(trophy.icon).to eq('fa-medal')
      expect(trophy.tier).to eq(:silver)

      ctx = double('ctx', :stat => 5)
      expect(trophy.earned_by?(ctx)).to be(true)

      ctx_low = double('ctx', :stat => 4)
      expect(trophy.earned_by?(ctx_low)).to be(false)
    end

    it 'registers a block-based trophy' do
      Trophy.define :mouse, :icon => 'fa-cheese' do |ctx|
        ctx.won_session_with_car?('Mouse')
      end

      trophy = Trophy.find(:mouse)
      expect(trophy.earned_by?(double(:won_session_with_car? => true))).to be(true)
      expect(trophy.earned_by?(double(:won_session_with_car? => false))).to be(false)
    end

    it 'rejects an unknown tier' do
      expect do
        Trophy.define :bad, :icon => 'fa-x', :tier => :diamond, :stat => :session_wins, :at_least => 1
      end.to raise_error(ArgumentError)
    end

    it 'requires either a block or a stat/at_least pair' do
      expect { Trophy.define :bad, :icon => 'fa-x' }.to raise_error(ArgumentError)
    end
  end

  describe '#name / #description' do
    it 'resolves from I18n keys' do
      Trophy.define :first_win, :icon => 'fa-flag-checkered', :stat => :session_wins, :at_least => 1
      # These keys exist in config/locales/en.yml
      expect(Trophy.find(:first_win).name).to eq(I18n.t('users.trophies.items.first_win.name'))
    end
  end
end

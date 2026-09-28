# frozen_string_literal: true

# Awards trophies to users based on their current state, and creates a
# notification for each newly-earned trophy.
#
# Only grants trophies the user doesn't already
# hold, so it is safe to run after every session import AND as a full backfill
# (see `rake trophies:recompute`).
class TrophyService
  # Sync a single user, returning the list of Trophy definitions newly awarded.
  def self.sync(user)
    new(user).sync
  end

  # Convenience: sync every registered participant of a session. Never raises;
  # trophy problems must not break session imports.
  def self.sync_session_participants(session)
    usernames = session.racer_result_entries.map(&:username).compact.uniq
    return if usernames.empty?

    User.where(:username.in => usernames).each { |user| sync(user) }
  rescue StandardError => e
    Rails.logger.error("[TrophyService] session participant sync failed: #{e.class}: #{e.message}")
    Sentry.capture_exception(e) if defined?(Sentry)
  end

  def initialize(user)
    @user = user
  end

  def sync
    return [] if @user.nil? || @user.stats.nil?

    context = TrophyContext.new(@user)
    newly_awarded = []

    Trophy.all.each do |trophy|
      next if @user.has_trophy?(trophy.key)
      next unless trophy.earned_by?(context)

      newly_awarded << trophy if @user.award_trophy(trophy.key)
    end

    return [] if newly_awarded.empty?

    @user.save
    newly_awarded.each { |trophy| notify(trophy) }
    newly_awarded
  end

  private

  def notify(trophy)
    Notification.create(
      :user => @user,
      :kind => 'trophy',
      :trophy_key => trophy.key.to_s
    )
  end
end

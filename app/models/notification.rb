# frozen_string_literal: true

# An on-site notification for a user. Kept in its own collection (rather than
# embedded) because notifications grow over time and we don't want to bloat the
# User document that is loaded on every request.
#
# The text is rendered at display time from I18n, so each viewer sees it in
# their own language. `kind` drives which template/string is used; trophy
# notifications also carry the earned trophy's key.
class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_users'

  belongs_to :user

  # e.g. 'trophy'. Kept generic so other notification kinds can be added later.
  field :kind, :type => String
  field :trophy_key, :type => String
  field :read, :type => Boolean, :default => false

  index({ :user_id => 1, :read => 1 })
  index({ :user_id => 1, :created_at => -1 })

  validates_presence_of :kind

  scope :unread, -> { where(:read => false) }
  scope :recent, -> { order_by(:created_at => :desc) }

  # The trophy definition behind a trophy notification (nil for other kinds or
  # if the definition was removed).
  def trophy
    Trophy.find(trophy_key)
  end
end

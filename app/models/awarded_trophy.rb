# frozen_string_literal: true

# A record of a trophy a user has earned. Embedded in User, keyed by the
# trophy's registry key. The definition (icon, name, tier, condition) lives in
# code (see Trophy); this only records "that" and "when" it was earned.
class AwardedTrophy
  include Mongoid::Document

  embedded_in :user

  field :key, :type => String
  field :awarded_at, :type => Time

  validates_presence_of :key

  # The corresponding definition, or nil if the definition was later removed.
  def definition
    Trophy.find(key)
  end
end

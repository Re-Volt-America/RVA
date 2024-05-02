class TrackList
  include Mongoid::Document

  embedded_in :weekly_schedule

  embeds_many :tracks

  field :category, :type => Integer
  field :track_count, :type => Integer

  validates_presence_of :category
  validates_presence_of :track_count
end

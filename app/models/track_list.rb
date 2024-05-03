class TrackList
  include Mongoid::Document

  embedded_in :weekly_schedule

  embeds_many :track_list_entries

  field :category, :type => Integer
  field :track_count, :type => Integer

  validates_presence_of :category
  validates_presence_of :track_count
end

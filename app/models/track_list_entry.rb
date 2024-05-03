class TrackListEntry
  include Mongoid::Document

  embedded_in :track_list

  field :name, :type => String
  field :stock, :type => Boolean
  field :lap_count, :type => Integer

  validates_presence_of :name
  validates_presence_of :stock
  validates_presence_of :lap_count
end

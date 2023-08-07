class Stats
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user

  field :race_wins, :type => Integer
  field :race_count, :type => Integer
  field :average_position, :type => Float
  field :participation_rate, :type => Float
  field :official_score, :type => Float
  field :obtained_points, :type => Float
  field :team_points, :type => Float

  validates_presence_of :race_wins
  validates_presence_of :race_count
  validates_presence_of :average_position
  validates_presence_of :participation_rate
  validates_presence_of :official_score
  validates_presence_of :obtained_points
  validates_presence_of :team_points
end

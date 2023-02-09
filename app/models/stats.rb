class Stats
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :race_wins, type: Integer
  field :race_count, type: Integer
  field :average_position, type: Float
  field :participation_rate, type: Float
  field :official_score, type: Float
  field :obtained_points, type: Float
  field :team_points, type: Float
end

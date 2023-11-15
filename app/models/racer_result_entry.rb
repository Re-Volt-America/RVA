class RacerResultEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, :type => String
  field :race_count, :type => Integer
  field :average_position, :type => Float
  field :obtained_points, :type => Integer
  field :official_score, :type => Float
  field :participation_multiplier, :type => Float
  field :team, :type => String
end

class RacerResultEntry
  include Mongoid::Document

  embedded_in :season
  embedded_in :ranking
  embedded_in :session

  field :username, :type => String
  field :country, :type => String
  field :session_count, :type => Integer
  field :race_count, :type => Integer
  field :positions_sum, :type => Integer
  field :average_position, :type => Float
  field :obtained_points, :type => Integer
  field :official_score, :type => Float
  field :participation_multiplier, :type => Float
  field :team, :type => String
end
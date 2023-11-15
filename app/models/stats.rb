class Stats
  include Mongoid::Document

  embedded_in :user

  field :race_wins, :type => Integer
  field :race_win_rate, :type => Float
  field :race_podiums, :type => Integer
  field :race_count, :type => Integer
  field :positions_sum, :type => Integer
  field :session_wins, :type => Integer
  field :session_win_rate, :type => Float
  field :session_podiums, :type => Integer
  field :session_count, :type => Integer
  field :average_position, :type => Float
  field :participation_rate, :type => Float
  field :official_score, :type => Float
  field :obtained_points, :type => Integer
end

class RacerResultEntry
  include Mongoid::Document

  # NOTE: This should never happen, but we cannot allow negative counts under any circumstances
  before_save :filter_negatives

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

  validates_presence_of :username

  def filter_negatives
    0 if session_count&.negative?
    0 if race_count&.negative?
    0 if positions_sum&.negative?
    0.0 if average_position && average_position < 0.0
    0 if obtained_points&.negative?
    0.0 if official_score && official_score < 0.0
    0.0 if participation_multiplier && participation_multiplier < 0.0
  end
end

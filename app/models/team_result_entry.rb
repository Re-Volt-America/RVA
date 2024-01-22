class TeamResultEntry
  include Mongoid::Document
  include TeamLogoUploader::Attachment(:team_logo)

  # NOTE: This should never happen, but we cannot allow negative counts under any circumstances
  before_save :filter_negative_points

  embedded_in :season
  embedded_in :ranking
  embedded_in :session

  field :name, :type => String
  field :short_name, :type => String
  field :team_logo_data, :type => String
  field :color, :type => String
  field :points, :type => Integer

  validates_presence_of :name
  validates_presence_of :short_name

  def filter_negative_points
    return if points.nil?

    points = 0 if points && points < 0
  end
end

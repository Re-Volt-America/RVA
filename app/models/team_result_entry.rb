class TeamResultEntry
  include Mongoid::Document
  include TeamLogoUploader::Attachment(:team_logo)

  before_save :filter_negatives

  embedded_in :season
  embedded_in :ranking
  embedded_in :session

  field :name, :type => String
  field :short_name, :type => String
  field :team_logo_data, :type => String
  field :points, :type => Integer

  validates_presence_of :name
  validates_presence_of :short_name

  def filter_negatives
    points = 0 if points && points < 0
  end
end

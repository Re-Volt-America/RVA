class Tournament
  include Mongoid::Document
  include TournamentBannerUploader::Attachment(:tournament_banner)
  include Mongoid::Timestamps

  store_in :database => 'rv_tournaments'

  belongs_to :season
  embeds_many :teams

  field :name, :type => String
  field :date, :type => Date
  field :format, :type => String
  field :tournament_banner_data, :type => String

  validates_presence_of :name
  validates_presence_of :date
  validates_presence_of :format
  validates_presence_of :tournament_banner
end

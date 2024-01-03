class Team
  include Mongoid::Document
  include TeamLogoUploader::Attachment(:team_logo)
  include Mongoid::Timestamps

  store_in :database => 'rv_teams'

  belongs_to :leader, class_name: 'User', :inverse_of => nil
  has_many :members, :class_name => 'User', :inverse_of => :team

  field :name, :type => String
  field :short_name, :type => String
  field :color, :type => String
  field :team_logo_data, :type => String
  field :points, :type => Integer, :default => 0

  validates_presence_of :leader
  validates_presence_of :name
  validates_presence_of :short_name
  validates_presence_of :color
  validates_presence_of :team_logo
end

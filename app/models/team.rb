class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_teams'

  embeds_many :users

  field :name, :type => String
  field :short_name, :type => String
  field :image, :type => String
  field :leader, :type => String

  validates_presence_of :name
  validates_presence_of :short_name
end

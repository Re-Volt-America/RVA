class Ranking
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_rankings'

  belongs_to :season
  has_many :sessions

  field :number, :type => Integer

  validates_presence_of :number
end

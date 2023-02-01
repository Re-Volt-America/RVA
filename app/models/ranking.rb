class Ranking
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :season
  has_many :sessions

  field :number, type: Integer
end

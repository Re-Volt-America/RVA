class Season
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  store_in :database => "rv_seasons"

  embeds_many :rankings
  has_many :cars
  has_many :tracks

  field :name, type: String
  field :start_date, type: Date
  field :end_date, type: Date
end

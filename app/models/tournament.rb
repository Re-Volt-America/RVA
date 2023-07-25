class Tournament
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => "rv_tournaments"

  belongs_to :season
  embeds_many :teams

  field :name, type: String
  field :date, type: Date
  field :format, type: String
end

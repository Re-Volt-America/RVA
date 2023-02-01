class Season
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => "rv_seasons"

  embeds_many :rankings

  field :name, type: String
  field :start_date, type: Date
  field :end_date, type: Date
end

class Session
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => "rv_sessions"

  belongs_to :ranking
  embeds_many :races

  field :host, type: String
  field :version, type: String
  field :physics, type: String
  field :protocol, type: String
  field :number, type: Integer
  field :date, type: Date
  field :sessionlog, type: String
end

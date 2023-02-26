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

  validates_presence_of :host
  validates_presence_of :version
  validates_presence_of :physics
  validates_presence_of :protocol
  validates_presence_of :number
  validates_presence_of :date
  validates_presence_of :sessionlog

  validates_uniqueness_of :number
end

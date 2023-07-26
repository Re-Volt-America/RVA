class Session
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => "rv_sessions"

  belongs_to :ranking
  embeds_many :races

  # FIXME: sessions SHOULD have a number field. Allow up to 18. (Probably up to 28 and split based on :teams)
  field :host, type: String
  field :version, type: String
  field :physics, type: String
  field :protocol, type: String
  field :pickups, type: Boolean
  field :date, type: Date
  #field :sessionlog, type: String # FIXME: maybe attached file?
  field :teams, type: Boolean
  field :car_class, type: Integer

  validates_presence_of :host
  validates_presence_of :version
  validates_presence_of :physics
  validates_presence_of :protocol
  validates_presence_of :date
  # validates_presence_of :sessionlog
  validates_presence_of :teams
  validates_presence_of :car_class
end

class RacerEntry
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :race

  has_one :car

  field :position, :type => Integer
  field :username, :type => String
  field :time, :type => String
  field :best_lap, :type => String
  field :finished, :type => Mongoid::Boolean
  field :cheating, :type => Mongoid::Boolean

  validates_presence_of :position
  validates_presence_of :username
  validates_presence_of :time
  validates_presence_of :best_lap
  validates_presence_of :finished
  validates_presence_of :cheating
end

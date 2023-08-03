class RacerEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :race

  has_one :car

  field :position, type: Integer
  field :username, type: String
  field :time, type: String
  field :best_lap, type: String
  field :finished, type: Mongoid::Boolean
  field :cheating, type: Mongoid::Boolean
end

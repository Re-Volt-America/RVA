class RacerEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :race
  embeds_one :car

  field :position, type: Integer
  field :name, type: String
  field :time, type: String
  field :best_lap, type: String
  field :finished, type: Mongoid::Boolean
  field :cheating, type: Mongoid::Boolean
end

class RacerEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :race
  embeds_one :car

  field :name, type: String
  field :best_lap, type: String
  field :finished, type: Mongoid::Boolean
  field :cheating, type: Mongoid::Boolean
  field :team, type: String
end

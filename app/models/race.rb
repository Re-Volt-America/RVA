class Race
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :session

  has_one :track
  embeds_many :racer_entries

  field :laps, type: Integer
  field :racers_count, type: Integer ## FIXME: maybe turn into a method? racers_count()... len(:racer_entries)...
end

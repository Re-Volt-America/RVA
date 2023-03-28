class Race
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :session
  embeds_one :track
  embeds_many :racer_entries

  field :laps, type: Integer
  field :racers_count, type: Integer ## FIXME: maybe turn into a method? racers_count()... len(:racer_entries)...
end

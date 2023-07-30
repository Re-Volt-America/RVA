class Race
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :session

  has_one :track
  embeds_many :racer_entries

  field :laps, type: Integer
  field :racers_count, type: Integer ## FIXME: maybe turn into a method? racers_count()... len(:racer_entries)...

  def get_racer_names
    names = []

    racer_entries.each do |entry|
      names << entry.name
    end

    names
  end

  def get_racer_entry_by_name(name)
    match = nil

    racer_entries.each do |entry|
      if entry.name.eql?(name)
        match = entry
        break
      end
    end

    match
  end
end

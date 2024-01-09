class Race
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :session

  embeds_many :racer_entries

  field :track_name, :type => String
  field :laps, :type => Integer

  # NOTE: total_racers is the number of racers that STARTED the race, not the number of racers that FINISHED it.
  # For the latter, use the finished_racers_count method.
  field :total_racers, :type => Integer

  validates_presence_of :track_name
  validates_presence_of :laps
  validates_presence_of :total_racers

  def finished_racers_count
    racer_entries.length
  end

  def get_racer_names
    names = []

    racer_entries.each do |entry|
      names << entry.username
    end

    names
  end

  def get_racer_entry_by_name(name)
    racer_entries.find { |e| e.username.eql?(name) }
  end
end

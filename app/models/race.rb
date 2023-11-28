class Race
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :session

  embeds_many :racer_entries

  field :track_name, :type => String
  field :laps, :type => Integer
  field :racers_count, :type => Integer

  validates_presence_of :track_name
  validates_presence_of :laps
  validates_presence_of :racers_count

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

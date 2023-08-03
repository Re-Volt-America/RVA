class Race
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :session

  has_one :track
  embeds_many :racer_entries

  field :laps, :type => Integer
  field :racers_count, :type => Integer

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

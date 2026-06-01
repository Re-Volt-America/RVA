class Race
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :session

  embeds_many :racer_entries

  belongs_to :track, :class_name => 'Track', :optional => true, :inverse_of => nil

  field :legacy_track_name, :type => String, :as => :track_name
  field :laps, :type => Integer

  # NOTE: total_racers is the number of racers that STARTED the race, not the number of racers that FINISHED it.
  # For the latter, use the finished_racers_count method.
  field :total_racers, :type => Integer

  validates_presence_of :laps
  validates_presence_of :total_racers
  validate :track_reference_present

  def finished_racers_count
    racer_entries.length
  end

  def track_name
    return legacy_track_name if legacy_track_name.present?

    track&.name
  end

  def track_name=(value)
    self.legacy_track_name = value
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

  private

  def track_reference_present
    return if track.present? || legacy_track_name.present?

    errors.add(:track, "can't be blank")
  end
end

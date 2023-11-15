class Session
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_sessions'

  belongs_to :ranking
  embeds_many :races
  embeds_many :racer_result_entries

  field :number, :type => Integer
  field :host, :type => String
  field :version, :type => String
  field :physics, :type => String
  field :protocol, :type => String
  field :pickups, :type => Boolean
  field :date, :type => Date
  # field :sessionlog, type: String # FIXME: maybe attached file?
  field :teams, :type => Boolean
  field :category, :type => Integer

  validates_presence_of :number
  validates_presence_of :host
  validates_presence_of :version
  validates_presence_of :physics
  validates_presence_of :protocol
  validates_presence_of :date
  # validates_presence_of :sessionlog
  validates_presence_of :teams
  validates_presence_of :category

  # Look for all RacerEntry models in this session which correspond to the passed racer.
  # @return An array containing each entry matching the racer.
  def get_racer_entries_arr_for_name(name)
    racer_entries_arr = []

    races.each do |race|
      race.racer_entries.each do |entry|
        racer_entries_arr << entry if entry.username.eql?(name)
      end
    end

    racer_entries_arr
  end
end

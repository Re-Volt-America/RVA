class Session
  include Mongoid::Document
  include SessionLogUploader::Attachment(:session_log)
  include Mongoid::Timestamps

  store_in :database => 'rv_sessions'

  belongs_to :ranking
  belongs_to :host, :class_name => 'User', :optional => true, :inverse_of => nil
  embeds_many :races
  embeds_many :racer_result_entries
  embeds_many :team_result_entries

  accepts_nested_attributes_for :racer_result_entries
  accepts_nested_attributes_for :team_result_entries

  field :number, :type => Integer
  field :legacy_host, :type => String
  field :version, :type => String
  field :physics, :type => String
  field :protocol, :type => String
  field :pickups, :type => Boolean
  field :date, :type => Date
  field :teams, :type => Boolean
  field :category, :type => Integer
  field :session_log_data, :type => String
  field :results_data, :type => Array, :default => []

  validates_presence_of :number
  validates_presence_of :version
  validates_presence_of :physics
  validates_presence_of :protocol
  validates_presence_of :date
  validates_presence_of :session_log
  validates_presence_of :teams
  validates_presence_of :category
  validate :host_reference_present

  def season
    ranking.season
  end

  def host_name
    host&.username || legacy_host
  end

  def host_name=(value)
    if value.is_a?(User)
      self.host = value
      self.legacy_host = value.username
      return
    end

    self.legacy_host = value
    return if value.nil? || value.to_s.strip.empty?

    self.host = User.where(:username => value.to_s.upcase).first
  end

  # Look for all RacerEntry models in this session which correspond to the passed racer.
  # @return An array containing each entry matching the racer.
  def get_racer_entries_arr(username)
    racer_entries_arr = []

    races.each do |race|
      race.racer_entries.each do |entry|
        racer_entries_arr << entry if entry.username.eql?(username)
      end
    end

    racer_entries_arr
  end

  private

  def host_reference_present
    return if host.present? || legacy_host.present?

    errors.add(:host, "can't be blank")
  end
end

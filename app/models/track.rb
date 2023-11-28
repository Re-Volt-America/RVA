class Track
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_tracks'

  belongs_to :season

  field :name, :type => String
  field :short_name, :type => String
  field :difficulty, :type => Integer
  field :length, :type => Integer
  field :folder_name, :type => String
  field :stock, :type => Boolean, :default => false

  validates_presence_of :name
  validates_presence_of :short_name
  validates_presence_of :difficulty
  validates_presence_of :length
  validates_presence_of :folder_name
  validates_presence_of :stock

  def name_variations
    [name, "#{name} R", "#{name} M", "#{name} RM"]
  end

  def thumbnail_url
    "#{ORG::TRACKS_REPO_URL}/gfx/#{folder_name}.bmp"
  end

  # @return [String] Capitalised name of the track difficulty as a string
  def difficulty_name
    SYS::RVGL_TRACK_DIFFICULTY_NAMES[difficulty].capitalize.gsub(/-[a-z]/, &:upcase)
  end
end

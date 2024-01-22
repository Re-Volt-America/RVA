class User
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_users'

  USERNAME_REGEX = /\A([A-Z0-9_]{1,16}|[0-9a-f]{24})\z/

  validates :email, :presence => true, :uniqueness => true
  validates :username, :presence => true, :uniqueness => true, :length => { :minimum => 2, :maximum => 16 }
  validates_format_of :username, :with => USERNAME_REGEX

  belongs_to :team, :optional => true, :inverse_of => :members
  has_one :team

  embeds_one :profile
  embeds_one :stats
  accepts_nested_attributes_for(:profile, :update_only => true, :allow_destroy => false)
  accepts_nested_attributes_for(:stats, :update_only => true, :allow_destroy => false)

  before_create :create_profile
  before_create :create_stats

  # NOTE: This should never happen, but we cannot allow negative counts under any circumstances
  before_save :filter_negative_stats

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :lockable,
         :trackable, :omniauthable

  ## Username
  field :username, :type => String

  ## Database authenticatable
  field :email,              :type => String, :default => ''
  field :encrypted_password, :type => String, :default => ''

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  field :locked_at,       :type => Time

  field :admin, :type => Boolean, :default => false
  field :mod, :type => Boolean, :default => false
  field :organizer, :type => Boolean, :default => false
  field :locale, :type => String, :default => 'en_us'
  field :country, :type => String

  def has_team?
    !self.team.nil?
  end

  def to_param
    username
  end

  def username=(username)
    self[:username] = username.upcase
  end

  def create_profile
    build_profile(:about => '',
                  :gender => '',
                  :public_email => '',
                  :location => '',
                  :discord => '',
                  :github => '',
                  :instagram => '',
                  :crowdin => '',
                  :steam => '',
                  :twitter => '',
                  :occupation => '',
                  :interests => '')
  end

  def create_stats
    build_stats(
      :race_wins => 0,
      :race_win_rate => 0.0,
      :race_podiums => 0,
      :race_count => 0,
      :positions_sum => 0,
      :session_wins => 0,
      :session_podiums => 0,
      :session_win_rate => 0.0,
      :session_count => 0,
      :average_position => 0.0,
      :participation_rate => 0.0,
      :official_score => 0.0,
      :obtained_points => 0
    )
  end

  def filter_negative_stats
    return if stats.nil?

    stats.race_wins = 0 if stats.race_wins && stats.race_wins < 0
    stats.race_win_rate = 0.0 if stats.race_win_rate && stats.race_win_rate < 0.0
    stats.race_podiums = 0 if stats.race_podiums && stats.race_podiums < 0
    stats.race_count = 0 if stats.race_count && stats.race_count < 0
    stats.positions_sum = 0 if stats.positions_sum && stats.positions_sum < 0
    stats.session_wins = 0 if stats.session_wins && stats.session_wins < 0
    stats.session_win_rate = 0.0 if stats.session_win_rate && stats.session_win_rate < 0.0
    stats.session_podiums = 0 if stats.session_podiums && stats.session_podiums < 0
    stats.session_count = 0 if stats.session_count && stats.session_count < 0
    stats.average_position = 0.0 if stats.average_position && stats.average_position < 0.0
    stats.participation_rate = 0.0 if stats.participation_rate && stats.participation_rate < 0.0
    stats.official_score = 0.0 if stats.official_score && stats.official_score < 0.0
    stats.obtained_points = 0 if stats.obtained_points && stats.obtained_points < 0
  end
end

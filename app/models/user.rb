class User
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_users'

  USERNAME_REGEX = /\A([a-zA-Z0-9_!.]{1,16}|[0-9a-f]{24})\z/

  validates :email, :presence => true, :uniqueness => true
  validates :username, :presence => true, :uniqueness => true, :length => { :minimum => 3, :maximum => 16 }
  validates_format_of :username, :with => USERNAME_REGEX

  belongs_to :team, :optional => true

  embeds_one :profile
  embeds_one :stats
  accepts_nested_attributes_for(:profile, :update_only => true, :allow_destroy => false)
  accepts_nested_attributes_for(:stats, :update_only => true, :allow_destroy => false)

  before_create :create_profile
  before_create :create_stats

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

  def to_param
    username
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
      :race_count => 0,
      :average_position => 0.0,
      :participation_rate => 0.0,
      :official_score => 0.0,
      :obtained_points => 0.0,
      :team_points => 0.0
    )
  end
end

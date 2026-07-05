class RacerEntry
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :race

  belongs_to :user, :class_name => 'User', :optional => true, :inverse_of => nil
  belongs_to :car, :class_name => 'Car', :optional => true, :inverse_of => nil

  field :legacy_car_name, :type => String, :as => :car_name
  field :position, :type => Integer
  field :legacy_username, :type => String, :as => :username
  field :time, :type => String
  field :best_lap, :type => String
  field :finished, :type => Mongoid::Boolean
  field :cheating, :type => Mongoid::Boolean

  validates_presence_of :position
  validates_presence_of :time
  validates_presence_of :best_lap
  validates_inclusion_of :finished, :in => [true, false]
  validates_inclusion_of :cheating, :in => [true, false]
  validate :user_reference_present
  validate :car_reference_present

  def username
    user&.username || legacy_username
  end

  def username=(value)
    self.legacy_username = value
  end

  def car_name
    car&.name || legacy_car_name
  end

  def car_name=(value)
    self.legacy_car_name = value
  end

  private

  def user_reference_present
    return if user.present? || legacy_username.present?

    errors.add(:user, "can't be blank")
  end

  def car_reference_present
    return if car.present? || legacy_car_name.present?

    errors.add(:car, "can't be blank")
  end
end

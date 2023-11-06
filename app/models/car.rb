class Car
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_cars'

  belongs_to :season

  field :name, :type => String
  field :speed, :type => Float
  field :accel, :type => Float
  field :weight, :type => Float
  field :multiplier, :type => Float
  field :folder_name, :type => String
  field :category, :type => Integer
  field :stock, :type => Boolean, :default => false

  validates_presence_of :name
  validates_presence_of :speed
  validates_presence_of :accel
  validates_presence_of :weight
  validates_presence_of :multiplier
  validates_presence_of :folder_name
  validates_presence_of :category
  validates_presence_of :stock

  def thumbnail_url
    "#{ORG::CARS_REPO_URL}/cars/#{folder_name}/carbox.bmp"
  end
end

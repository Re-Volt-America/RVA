class Car
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => "rv_cars"

  belongs_to :season

  field :name, :type => String
  field :speed, :type => Float
  field :accel, :type => Float
  field :weight, :type => Float
  field :multiplier, :type => Float
  field :folder_name, :type => String
end

class Car
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => "rv_cars"

  field :name, :type => String
  field :speed, :type => Float
  field :accel, :type => Float
  field :weight, :type => Float
  field :folder_name, :type => String
end

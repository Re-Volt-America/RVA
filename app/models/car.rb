class Car
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :speed, :type => Float
  field :accel, :type => Float
  field :weight, :type => Float
  field :folder_name, :type => String
end

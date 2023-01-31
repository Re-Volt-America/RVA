class Track
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :difficulty, :type => Integer
  field :length, :type => Integer
  field :folder_name, :type => String
end

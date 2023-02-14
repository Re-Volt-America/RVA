class Track
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => "rv_tracks"

  belongs_to :season

  field :name, :type => String
  field :difficulty, :type => Integer
  field :length, :type => Integer
  field :folder_name, :type => String
end

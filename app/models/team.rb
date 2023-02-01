class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :short_name, type: String
  field :image, type: String
  field :leader, type: String
end

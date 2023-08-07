class Profile
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user

  field :about, :type => String
  field :gender, :type => String
  field :public_email, :type => String
  field :location, :type => String
  field :discord, :type => String
  field :github, :type => String
  field :instagram, :type => String
  field :crowdin, :type => String
  field :steam, :type => String
  field :twitter, :type => String
  field :occupation, :type => String
  field :interests, :type => String

  validates_presence_of :about
  validates_presence_of :gender
  validates_presence_of :public_email
  validates_presence_of :location
  validates_presence_of :discord
  validates_presence_of :github
  validates_presence_of :instagram
  validates_presence_of :crowdin
  validates_presence_of :steam
  validates_presence_of :twitter
  validates_presence_of :occupation
  validates_presence_of :interests
end

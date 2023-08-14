class Profile
  include Mongoid::Document

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
end

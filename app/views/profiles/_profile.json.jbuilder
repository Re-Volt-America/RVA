json.extract! profile, :id, :about, :gender, :public_email, :location, :discord, :github, :instagram, :crowdin, :steam,
              :twitter, :occupation, :interests, :created_at, :updated_at
json.url profile_url(profile, :format => :json)

json.extract! profile, :id, :about, :gender, :public_email, :location, :discord, :github, :instagram, :crowdin, :steam,
              :twitter, :occupation, :interests
json.url profile_url(profile, :format => :json)

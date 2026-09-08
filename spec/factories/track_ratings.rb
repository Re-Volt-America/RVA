FactoryBot.define do
  factory :track_rating do
    track
    user
    gameplay_rating { 4 }
    visuals_rating { 4 }
    audio_rating { 4 }
    fun_rating { 4 }
  end
end

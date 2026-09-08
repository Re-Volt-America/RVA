FactoryBot.define do
  factory :track do
    season
    sequence(:name) { |n| "Test Track #{n}" }
    short_name { 'TT' }
    difficulty { 0 }
    length { 500 }
    folder_name { 'testtrack' }
    author { 'Tester' }
    stock { true }
    lego { true }
    active { true }
    average_lap_time { 45 }
  end
end

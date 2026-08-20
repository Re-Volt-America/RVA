FactoryBot.define do
  factory :season do
    sequence(:name) { |n| "Season #{n}" }
    start_date { Date.current }
    current { true }
  end
end

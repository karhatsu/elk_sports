FactoryBot.define do
  factory :race do
    district
    sport_key { Sport.default_sport_key }
    name { 'Championships' }
    sequence(:location) { |n| "Tervo#{n}" }
    start_date { '2010-08-14' }
    start_interval_seconds { 60 }
    start_order { Race::START_ORDER_BY_SERIES }
    batch_size { 0 }
    batch_interval_seconds { 180 }
    start_time { '00:00:00' }
  end
end

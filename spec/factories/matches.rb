FactoryBot.define do
  factory :match do
    association :white_player, factory: :player
    association :black_player, factory: :player
    status { 0 }
    played_at { Time.current }

     trait :pending do
      status { 0 }
    end

    trait :in_progress do
      status { 1 }
    end

    trait :completed do
      status { 2 }
    end

    trait :cancelled do
      status { 3 }
    end
  end
end

FactoryBot.define do
  factory :match_result do
    association :match
    association :winner, factory: :player
    association :loser, factory: :player
    draw { false }

    trait :draw do
      draw { true }
    end
  end
end

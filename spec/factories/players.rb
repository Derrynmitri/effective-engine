FactoryBot.define do
  factory :player do
    association :user

    sequence(:name) { |n| "Player #{n}" }
    sequence(:surname) { |n| "Surname #{n}" }
    birthday { Date.new(1990, 1, 1) }
    sequence(:ranking) { |n| n + 1 }
  end
end

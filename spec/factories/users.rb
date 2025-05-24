FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :player }

    trait :admin do
      role { :admin }
      sequence(:email) { |n| "admin#{n}@example.com" }
    end

    trait :referee do
      role { :referee }
      sequence(:email) { |n| "referee#{n}@example.com" }
    end

    trait :player do
      role { :player }
      sequence(:email) { |n| "player#{n}@example.com" }
    end

    factory :admin_user, traits: [ :admin ]
    factory :referee_user, traits: [ :referee ]
    factory :player_user, traits: [ :player ]
  end
end

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { Faker::Internet.password }
    confirmed_at { Time.zone.now }

    trait :basic

    trait :moderator do
      roles { [Role.moderator] }
    end

    trait :admin do
      roles { [Role.admin] }
    end

    trait :superadmin do
      roles { [Role.superadmin] }
    end
  end
end

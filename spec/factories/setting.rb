FactoryBot.define do
  factory :setting do
    key { Faker::Lorem.word }
    type { :string }
    description { Faker::Lorem.paragraph }
  end
end

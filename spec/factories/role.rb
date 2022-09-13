FactoryBot.define do
  factory :role do
    name { Faker::Internet.name }
  end
end

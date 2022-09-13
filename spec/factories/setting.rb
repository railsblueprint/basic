FactoryBot.define do
  factory :setting do
    self.alias { Faker::Lorem.word }
    type { :string }
    description { Faker::Lorem.paragraph }
  end
end

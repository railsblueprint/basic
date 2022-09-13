FactoryBot.define do
  factory :post do
    title { Faker::Hacker.say_something_smart }

    body {
      Array.new(rand(10)) {
        Faker::Lorem.paragraph(sentence_count: rand(10), supplemental: true)
      }.join("<br/>")
    }

    user
  end
end

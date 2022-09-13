FactoryBot.define do
  factory :mail_template do
    self.alias { Faker::Hacker.say_something_smart.underscore }
    subject { Faker::Hacker.say_something_smart }
    layout { MailTemplate.available_layouts.sample }
    body {
      Array.new(rand(10)) {
        Faker::Lorem.paragraph(sentence_count: rand(10), supplemental: true)
      }.join("<br/>")
    }
  end
end

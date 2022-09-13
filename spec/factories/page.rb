FactoryBot.define do
  factory :page do
    title { Faker::Hacker.say_something_smart.split[0..2].join(" ") }

    body {
      "<h1>#{title}</h1>" + Array.new(rand(30)) {
        Faker::Lorem.paragraph(sentence_count: rand(30), supplemental: true)
      }.join("<br/>")
    }

    url { title.parameterize }
    seo_title { title.gsub("''", " ") }
    seo_keywords { title.gsub(" ", ", ") }
    seo_description { Faker::Lorem.paragraph(sentence_count: rand(1..10), supplemental: true) }
    icon {
      %w[app at award basket battery bookmark chat-left-text cloud cpu envelope].sample
    }
    show_in_sidebar { rand(10) == 0 }
    active { true }
  end
end

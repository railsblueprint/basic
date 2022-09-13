def main
  return seed_all unless ENV["what"].present?
  ENV["what"].split(",").each do |what|
    if Object.respond_to?("seed_#{what}", true)
      send :"seed_#{what}"
    else
      puts "Unknown seed #{what}"
    end
  end
end

def seed_admin
  admin = User.create(
    email: "superadmin@localhost",
    password: "12345678",
    confirmed_at: Time.now,
    first_name: "Super",
    last_name:  "Admin",
    job: "Superadmin",
    company: "Rails Blueprint",
  )
  admin.add_role :superadmin
end


def seed_users
  admin = User.create(
    email: "admin@localhost",
    password: "12345678",
    confirmed_at: Time.now,
    first_name: "Just",
    last_name:  "Admin",
    job: "Admin",
    company: "Rails Blueprint",
    )
  admin.add_role :admin
  admin = User.create(
    email: "moderator@localhost",
    password: "12345678",
    confirmed_at: Time.now,
    first_name: "Angry",
    last_name:  "Moderator",
    job: "Moderator",
    company: "Rails Blueprint",
    )
  admin.add_role :moderator



  100.times do
    date = Time.now - rand(10000)

    User.create(
      password: SecureRandom.hex(32),
      email: Faker::Internet.email,
      first_name: Faker::Name.first_name,
      last_name:  Faker::Name.last_name,
      job: Faker::Job.position,
      company: Faker::Company.name,
      about: Faker::Hacker.say_something_smart,
      phone: Faker::PhoneNumber.phone_number,
      country: Faker::Address.country,
      address: Faker::Address.full_address,
      twitter_profile: rand(2) == 1 ? "https://twitter.com" : nil,
      linkedin_profile: rand(2) == 1? "https://linkedin.com" : nil,
      facebook_profile: rand(2) == 1? "https://facebook.com" : nil,
      instagram_profile: rand(2) == 1? "https://instagram.com" : nil,
      confirmed_at: date,
      created_at: date,
      updated_at: date
    )
  end
end

def seed_posts
  users = User.all

  50.times do |i|
    body = rand(10).times.map do
      Faker::Lorem.paragraph(sentence_count: rand(10), supplemental: true)
    end.join("<br/>")

    Post.create(
      user: users.sample,
      title: Faker::Hacker.say_something_smart,
      body: body,
      created_at: Time.now - i * 100
    )
  end
end

def seed_pages
  10.times do |i|
    title = Faker::Hacker.say_something_smart

    body = "<h1>#{title}</h1>" + rand(30).times.map do
      Faker::Lorem.paragraph(sentence_count: rand(30), supplemental: true)
    end.join("<br/>")

    Page.create(
      title: title.split(" ")[0..2].join(" "),
      url: title.parameterize,
      body: body,
      seo_title: title,
      seo_keywords: title.gsub(" ", ", "),
      seo_description: Faker::Lorem.paragraph(sentence_count: rand(10), supplemental: true),
      icon: ["app", "at", "award", "basket", "battery", "bookmark", "chat-left-text", "cloud", "cpu", "envelope"].sample,
      show_in_sidebar: i<2 ,
      active: true
    )
  end
end

def seed_all
  seed_admin
end

def seed_demo
  seed_users
  seed_posts
  seed_pages
end


main

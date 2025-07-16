source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
# gem "sqlite3", "~> 1.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 6.4.3"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production

gem "hiredis"
gem "redis", ">= 4.0", require: ["redis", "redis/connection/hiredis"]

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Ruby 3.4 compatibility
gem "csv"
gem "observer"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

gem "apexcharts", "~> 0.2.0"
gem "awesome_print", "~> 1.9"
gem "devise", "~> 4.8"
gem "devise-i18n"
gem "dotenv-rails", "~> 2.7"
gem "font_awesome5_rails", "~> 1.5"
gem "font-awesome-rails", "~> 4.7"
gem "groupdate", "~> 6.0"
gem "inline_svg", "~> 1.8"
gem "meta-tags", "~> 2.16"
gem "pg", "~> 1.2"
gem "pghero", "~> 3.1"
gem "sidekiq", "~> 6.3"
gem "whenever", "~> 1.0", require: false

gem "faker", "~> 2.19"

# group :production do
#  gem "terser", "~> 1.1"
# end

gem "tinymce-rails", "~> 5.10"
gem "tinymce-rails-langs", "~> 5.20200505"

# optional: just for generate svg
gem "active_link_to", "~> 1.0"
gem "audited", "~> 5.0"
gem "aws-sdk-s3", "~> 1.113"
gem "blueprint_config"
gem "bootstrap5-kaminari-views", "~> 0.0.1"
gem "bootstrap_form", "~> 5.0"
gem "bootstrap-icons-helper", "~> 2.0"
gem "bootstrap_icons_rubygem", "~> 0.1.0"
gem "bundle-audit", "~> 0.1.0"
gem "cable_ready", "~> 5.0.pre9"
gem "creek", "~> 2.5"
gem "dartsass-rails", "~> 0.4.0"
gem "data_migrate", "~> 11.0"
gem "down", "~> 5.3"
gem "faraday", "~> 2.2"
gem "faraday-multipart", "~> 1.0"
gem "friendly_id", "~> 5.4"
gem "good_job", "~> 4.0"
gem "hotwire-livereload", github: "elik-ru/hotwire-livereload"
gem "i18n-tasks", "~> 1.0.13"
gem "inky-rb", require: "inky"
gem "its-it", "~> 1.3"
gem "kaminari", "~> 1.2"
gem "liquid"
gem "loaf", "~> 0.10.0"
gem "mail", "~> 2.7"
gem "net-http", "~> 0.2.0"
gem "newrelic_rpm"
gem "nokogiri", "~> 1.13"
gem "pagy", "~> 5.10"
gem "pg_search", "~> 2.3"
gem "premailer-rails"
gem "quill-editor-rails"
gem "rake", "~> 13.0"
gem "redis-rails-instrumentation", "~> 1.0"
gem "rolify", "~> 6.0"
gem "rollbar", "~> 3.3"
gem "rollbar-user_informer", github: "railsblueprint/rollbar-user_informer"
gem "roo", "~> 2.8"
gem "sd_notify", "~> 0.1.1"
gem "simple_xlsx_reader", "~> 1.0"
gem "slim", "~> 4.1"
gem "stimulus_reflex", "~> 3.5.pre9"
gem "uri", "~> 0.13.2"
gem "view_component"
gem "view_component_reflex"
gem "wannabe_bool", "~> 0.7.1"
gem "wisper", "~> 2.0"
# gem "propshaft", "~> 0.6.4"
gem "aws-sdk-rails", "~> 3.6"
gem "dry-struct", "~> 1.3"
gem "dry-validation", "~> 1.10"
gem "memoit", "~> 0.4.1"
gem "pundit", "~> 2.3"
gem "sweet_notifications", github: "elik-ru/sweet_notifications", branch: "rails-7.1-compatibility"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  # fix net-ssh bug for deploy
  gem "bcrypt_pbkdf", "~> 1.1"
  gem "ed25519", "~> 1.3"

  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false

  # gem "html2slim-ruby3"  # Commented out due to hpricot Ruby 3.3 compatibility issues

  gem "active_record_query_trace"
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener", "~> 1.7"
  gem "mina", require: false
  gem "mina-data-migrate", require: false
  gem "mina-multistage", require: false
  gem "mina-puma-nginx", require: false
  gem "mina-puma-systemd", require: false
  gem "mina-rollbar-3", require: false
  gem "mina-secrets-transfer", require: false
  gem "mina-whenever-env", require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "factory_bot"
  gem "factory_bot_rails", "6.2.0"
  gem "rails-controller-testing"
  gem "rspec-collection_matchers"
  gem "rspec-html-matchers"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "spring-commands-rspec"
  gem "webdrivers"
  gem "wisper-rspec"
end

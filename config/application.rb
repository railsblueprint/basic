require_relative "boot"

require "rails/all"
require 'good_job/engine'

# Prevent problems with double loading between `development` and `test` environments
if defined?(Rake.application) && Rake.application.top_level_tasks.grep(/^(default$|spec(:|$))/).any?
  ENV['RAILS_ENV'] ||= 'test'
end

require "rspec-rails" if Rails.env.development? || Rails.env.test?

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


module Railsblueprint
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.active_job.queue_adapter = :good_job
    config.exceptions_app = self.routes

    # config.assets.cache = false
    config.assets.cache_store = :null_store

    config.i18n.fallbacks = true

    config.before_configuration do |app|
      require "#{root}/lib/app_config"
    end

    config.after_initialize do |app|
      app.routes.default_url_options = app.config.action_mailer.default_url_options

      AppConfig.load_settings
    end

    config.autoload_paths << "#{root}/app/liquid"


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
Rails.backtrace_cleaner.remove_silencers!

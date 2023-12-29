require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.

  # Stimulus reflex will force to use caching anyways
  if true 
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :redis_cache_store, {url: AppConfig.dig(:redis, :url) }

    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.session_store :cache_store, key: "_#{AppConfig.app_prefix}_sessions_development", compress: true, pool_size: 5, expire_after: 1.year

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = AppConfig.active_storage.service

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.action_mailer.perform_deliveries = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = false

  # Suppress logger output for asset requests.
  config.assets.quiet = true
  config.assets.debug = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  config.action_mailer.delivery_method     = AppConfig.dig(:action_mailer, :delivery_method)
  config.action_mailer.smtp_settings       = AppConfig.dig(:action_mailer, :smtp_settings)
  config.action_mailer.default_url_options = AppConfig.dig(:action_mailer, :default_url_options)
  if AppConfig.dig(:action_mailer, :configuration_method).present?
    config.action_mailer.send(
      "#{AppConfig.dig(:action_mailer, :configuration_method)}=",
      AppConfig.dig(:action_mailer, :configuration_data),
      )
  end

  config.web_console.whitelisted_ips = '0.0.0.0'
  config.web_console.development_only = false
end

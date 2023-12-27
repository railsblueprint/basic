require "econfig"

require_relative "app_config/options"
require_relative "app_config/credentials_backend"
require_relative "app_config/yaml_backend"

module AppConfig
  class << self
    def load_settings
      Econfig.instance.backends.push Setting
    end

    def dig *args
      key = args.shift
      args.any? ? send(key)&.dig(*args) : send(key)
    end

    def method_missing(name, *args)
      Econfig.instance.send(name, *args).tap {|value|
        break Options.new(value) if value.is_a?(Hash)
      }
    end

    def respond_to?(...)
      true
    end
  end

  if defined?(Rails)
    Econfig.root = Rails.root
    Econfig.env = Rails.env
    Rails.application.config.app = Econfig.instance
  else
    Econfig.root = "#{File.dirname(__FILE__)}/.."
    Econfig.env = ENV["RAILS_ENV"] || "development"
  end

  Econfig.instance.backends.clear
  Econfig.instance.backends.push Econfig::ENV.new
  Econfig.instance.backends.push YAMLBackend.new
  Econfig.instance.backends.push CredentialsBackend

  Econfig.init
end
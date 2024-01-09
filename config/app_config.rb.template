require "blueprint_config"

BlueprintConfig.env_backend_options = {whitelist_keys: [:port]}

unless defined?(Rails)
  BlueprintConfig.root ||= "#{File.dirname(__FILE__)}/.."
  BlueprintConfig.env ||= ENV["RAILS_ENV"] || "development"

  BlueprintConfig.define_shortcut
  BlueprintConfig.init
end

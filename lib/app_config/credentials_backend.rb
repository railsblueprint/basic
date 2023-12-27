require "active_support/encrypted_configuration"

module AppConfig
  class CredentialsBackend
    def self.get(key)
      credentials.send(key.to_sym)
    end

    def self.credentials
      if defined?(Rails)
        Rails.application.credentials
      else
        ActiveSupport::EncryptedConfiguration.new(
          config_path: "config/credentials.yml.enc",
          key_path: "config/master.key",
          env_key: "RAILS_MASTER_KEY",
          raise_if_missing_key: false
        )
      end
    end
  end
end

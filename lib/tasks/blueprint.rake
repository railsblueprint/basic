require "rails/generators/rails/encryption_key_file/encryption_key_file_generator"

class CredentialsGenerator < Rails::Generators::Base
  argument :content_path, default: "config/credentials.yml.enc"
  argument :key_path, default: "config/master.key"

  source_root Rails.root

  def add_credentials_file
    in_root do
      ensure_key!

      if File.exist?(content_path)
        say "Skipping existing #{content_path}", :yellow
      else
        say "Creating #{content_path}", :green
        render_template_to_encrypted_file
      end
    end
  end

  private

  def ensure_key!
    if File.exist?(key_path)
      say "Skipping existing #{key_path}", :yellow
      return
    end
    say "Creating #{key_path}", :green

    encryption_key_file_generator = Rails::Generators::EncryptionKeyFileGenerator.new
    encryption_key_file_generator.add_key_file_silently(key_path)
    encryption_key_file_generator.ignore_key_file(key_path)
  end

  def encrypted_file
    ActiveSupport::EncryptedConfiguration.new(
      config_path:          content_path,
      key_path:,
      env_key:              "RAILS_MASTER_KEY",
      raise_if_missing_key: true
    )
  end

  memoize def secret_key_base
    SecureRandom.hex(64)
  end

  def render_template_to_encrypted_file
    encrypted_file.change do |tmp_path|
      template("#{content_path}.template", tmp_path, force: true, verbose: false)
    end
  end
end

class ConfigGenerator < Rails::Generators::Base
  argument :content_path
  source_root Rails.root
  def generate
    in_root do
      render_template
    end
  end

  def app_prefix
    AppConfig.app_prefix || ENV["app_prefix"] ||
      ask("What is the short app name? (e.g. cool_app)").tap { |app_prefix|
        break ENV["app_prefix"] = app_prefix.parameterize.underscore
      }
  end

  def git_repo_url
    `git remote get-url origin`.strip
  end

  private

  def render_template
    template("#{content_path}.template", content_path)
  end
end

# rubocop:disable Rails/RakeEnvironment
namespace :blueprint do
  desc "Initialise new project"
  task :init do
    Thor.new.say "Initialising new project", :green

    [
      %w[config/master.key config/credentials.yml.enc],
      %w[config/credentials/staging.key config/credentials/staging.yml.enc],
      %w[config/credentials/production.key config/credentials/production.yml.enc]
    ].each do |(key, file)|
      CredentialsGenerator.new([file, key]).invoke_all
    end

    %w[
      .env
      config/app.yml
      config/cable.yml
      config/database.yml
      config/storage.yml
      config/schedule.rb
      config/importmap.rb
      config/i18n-tasks.yml
      config/deploy.rb
      config/deploy/staging.rb
      config/deploy/production.rb
      package.json
    ].each do |file|
      ConfigGenerator.new([file]).invoke_all
    end
  end
  # rubocop:enable Rails/RakeEnvironment
end

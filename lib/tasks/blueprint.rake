require "rails/generators/rails/encryption_key_file/encryption_key_file_generator"
require "English"

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
  task :init, [:app_name] do |_t, args|
    Thor.new.say "Initialising new project", :green

    # Set app name from command line argument or environment variable
    ENV["app_prefix"] = args[:app_name].parameterize.underscore if args[:app_name]

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
      config/app_config.rb
      config/cable.yml
      config/database.yml
      config/storage.yml
      config/schedule.rb
      config/importmap.rb
      config/i18n-tasks.yml
      config/newrelic.yml
      config/deploy.rb
      config/deploy/staging.rb
      config/deploy/production.rb
      package.json
    ].each do |file|
      ConfigGenerator.new([file]).invoke_all
    end

    # Save template metadata for future updates
    TemplateTracker.new.save_all_templates
    Thor.new.say "Template tracking initialized for future updates", :green
  end

  desc "Check for template updates and optionally apply them"
  # rubocop:disable Metrics/BlockNesting
  task check_templates: :environment do
    require "digest"
    require "yaml"
    require "diffy"

    tracker = TemplateTracker.new

    if tracker.tracking_initialized?
      changes = tracker.check_for_updates

      if changes.empty?
        Thor.new.say "All templates are up to date!", :green
      else
        Thor.new.say "Found #{changes.size} template(s) with updates:", :yellow
        changes.each do |change|
          Thor.new.say "\n  #{change[:file]}:", :cyan
          Thor.new.say "    Status: #{change[:status]}", :yellow
          if change[:status] == :modified
            Thor.new.say "    Local changes: #{change[:has_local_changes] ? 'Yes' : 'No'}",
                         change[:has_local_changes] ? :red : :green
          end
        end

        tracker.apply_updates(changes) if Thor.new.yes?("\nWould you like to review and apply updates? (y/n)")
      end
    else
      Thor.new.say "Template tracking not initialized!", :yellow
      Thor.new.say "Run 'rails blueprint:init_template_tracking' to enable template update detection.", :yellow
      Thor.new.say "This will create a baseline for tracking future template changes.", :cyan
    end
  end
  # rubocop:enable Metrics/BlockNesting

  desc "Force update all templates (creates backups)"
  task update_templates: :environment do
    tracker = TemplateTracker.new

    unless tracker.tracking_initialized?
      Thor.new.say "Template tracking not initialized!", :yellow
      Thor.new.say "Initializing template tracking now...", :cyan
      tracker.save_all_templates
    end

    tracker.force_update_all
  end

  desc "Initialize template tracking (only needed for projects created before template tracking was added)"
  task init_template_tracking: :environment do
    tracker = TemplateTracker.new
    tracker.save_all_templates
    Thor.new.say "Template tracking initialized!", :green
  end
  # rubocop:enable Rails/RakeEnvironment
end

class TemplateTracker
  TRACKING_FILE = Rails.root.join(".blueprint_templates")
  TEMPLATE_FILES = %w[
    .env
    config/app.yml
    config/app_config.rb
    config/cable.yml
    config/database.yml
    config/storage.yml
    config/schedule.rb
    config/importmap.rb
    config/i18n-tasks.yml
    config/newrelic.yml
    config/deploy.rb
    config/deploy/staging.rb
    config/deploy/production.rb
    package.json
  ].freeze

  def initialize
    @templates = load_tracking_data
  end

  def tracking_initialized?
    File.exist?(TRACKING_FILE) && !@templates.empty?
  end

  def save_all_templates
    TEMPLATE_FILES.each do |file|
      template_path = Rails.root.join("#{file}.template")
      next unless File.exist?(template_path)

      @templates[file] = {
        checksum:   calculate_checksum(template_path),
        version:    blueprint_version,
        updated_at: Time.current.to_s
      }
    end
    save_tracking_data
  end

  def check_for_updates
    changes = []

    TEMPLATE_FILES.each do |file|
      change = check_single_template(file)
      changes << change if change
    end

    changes
  end

  private

  def check_single_template(file)
    template_path = Rails.root.join("#{file}.template")
    local_path = Rails.root.join(file)

    return nil unless File.exist?(template_path)

    current_checksum = calculate_checksum(template_path)
    tracked = @templates[file]

    if tracked.nil?
      { file:, status: :new, template_path:, local_path: }
    elsif tracked[:checksum] != current_checksum
      build_modified_change(file, template_path, local_path, tracked, current_checksum)
    end
  end

  def build_modified_change(file, template_path, local_path, tracked, current_checksum)
    has_local_changes = File.exist?(local_path) &&
                       !FileUtils.identical?(template_path, local_path)
    {
      file:,
      status:            :modified,
      template_path:,
      local_path:,
      has_local_changes:,
      old_checksum:      tracked[:checksum],
      new_checksum:      current_checksum
    }
  end

  public

  # rubocop:disable Metrics/AbcSize
  def apply_updates(changes)
    changes.each do |change|
      Thor.new.say "\nProcessing #{change[:file]}...", :cyan

      if !File.exist?(change[:local_path])
        # File doesn't exist locally, just copy it
        FileUtils.cp(change[:template_path], change[:local_path])
        Thor.new.say "  Created new file", :green
      elsif change[:has_local_changes]
        # Has local changes, offer merge options
        handle_merge_conflict(change)
      else
        # No local changes, safe to update
        FileUtils.cp(change[:template_path], change[:local_path])
        Thor.new.say "  Updated (no local changes)", :green
      end

      # Update tracking
      @templates[change[:file]] = {
        checksum:   calculate_checksum(change[:template_path]),
        version:    blueprint_version,
        updated_at: Time.current.to_s
      }
    end

    save_tracking_data
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def force_update_all
    Thor.new.say "WARNING: Force update copies raw template files without processing ERB placeholders!", :red
    Thor.new.say "This command is intended for development use only.", :yellow
    Thor.new.say "For normal updates, use 'rails blueprint:check_templates'", :yellow

    unless Thor.new.yes?("\nDo you want to continue? (y/n)")
      Thor.new.say "Aborted.", :red
      return
    end

    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    backup_dir = Rails.root.join("tmp/blueprint_backups/#{timestamp}")
    FileUtils.mkdir_p(backup_dir)

    TEMPLATE_FILES.each do |file|
      template_path = Rails.root.join("#{file}.template")
      local_path = Rails.root.join(file)

      next unless File.exist?(template_path)

      if File.exist?(local_path)
        backup_path = backup_dir.join(file)
        FileUtils.mkdir_p(backup_path.dirname)
        FileUtils.cp(local_path, backup_path)
      end

      FileUtils.cp(template_path, local_path)
    end

    save_all_templates
    Thor.new.say "All templates updated. Backups saved to: #{backup_dir}", :green
    Thor.new.say "IMPORTANT: You need to manually process ERB placeholders in the updated files!", :red
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def handle_merge_conflict(change)
    show_diff(change)
    show_merge_options
    choice = Thor.new.ask("  Choose option:")
    process_merge_choice(choice, change)
  end

  def show_diff(change)
    diff = Diffy::Diff.new(
      File.read(change[:local_path]),
      File.read(change[:template_path]),
      context: 3
    )
    Thor.new.say "  Diff:", :yellow
    puts diff.to_s(:color)
  end

  def show_merge_options
    merge_options.each { |k, v| Thor.new.say "  #{k}) #{v}" }
  end

  def merge_options
    {
      "1" => "Keep local version",
      "2" => "Use template version",
      "3" => "View full diff",
      "4" => "Auto-merge (attempt three-way merge)",
      "5" => "Create .merge file for manual resolution",
      "6" => "Skip this file"
    }
  end

  def process_merge_choice(choice, change)
    case choice
    when "1" then keep_local_version
    when "2" then use_template_version(change)
    when "3" then view_full_diff(change)
    when "4" then try_auto_merge(change)
    when "5" then create_merge_file(change)
    when "6" then skip_file
    else handle_merge_conflict(change) # Invalid choice, try again
    end
  end

  def keep_local_version
    Thor.new.say "  Keeping local version", :green
  end

  def use_template_version(change)
    backup_path = "#{change[:local_path]}.blueprint_backup"
    FileUtils.cp(change[:local_path], backup_path)
    FileUtils.cp(change[:template_path], change[:local_path])
    Thor.new.say "  Updated to template version (backup: #{backup_path})", :green
  end

  def view_full_diff(change)
    diff = Diffy::Diff.new(
      File.read(change[:local_path]),
      File.read(change[:template_path]),
      context: 3
    )
    puts diff.to_s(:text)
    handle_merge_conflict(change) # Show options again
  end

  def try_auto_merge(change)
    if attempt_auto_merge(change)
      Thor.new.say "  Successfully auto-merged changes!", :green
    else
      Thor.new.say "  Auto-merge failed, please choose another option", :red
      handle_merge_conflict(change)
    end
  end

  def create_merge_file(change)
    merge_path = "#{change[:local_path]}.blueprint_merge"
    File.write(merge_path, <<~MERGE)
      <<<<<<< LOCAL VERSION
      #{File.read(change[:local_path])}
      =======
      #{File.read(change[:template_path])}
      >>>>>>> TEMPLATE VERSION
    MERGE
    Thor.new.say "  Created merge file: #{merge_path}", :yellow
  end

  def skip_file
    Thor.new.say "  Skipped", :yellow
    nil
  end

  def attempt_auto_merge(change)
    old_template_path = find_previous_template_version(change[:file])
    return false unless old_template_path

    require "tempfile"
    temp_files = create_temp_files_for_merge

    begin
      write_merge_content(temp_files, old_template_path, change)
      merged_content = perform_git_merge(temp_files)
      return false unless merged_content

      handle_merge_result?(merged_content, change)
    ensure
      cleanup_temp_files(temp_files.values)
    end
  end

  def create_temp_files_for_merge
    {
      base:     Tempfile.new("base"),
      local:    Tempfile.new("local"),
      template: Tempfile.new("template"),
      result:   Tempfile.new("result")
    }
  end

  def write_merge_content(temp_files, old_template_path, change)
    temp_files[:base].write(File.read(old_template_path))
    temp_files[:local].write(File.read(change[:local_path]))
    temp_files[:template].write(File.read(change[:template_path]))

    [:base, :local, :template].each { |key| temp_files[key].close }
  end

  def perform_git_merge(temp_files)
    merge_cmd = build_merge_command(temp_files)
    merge_status = system(merge_cmd)

    return nil unless merge_status || $CHILD_STATUS.exitstatus == 1

    File.read(temp_files[:result].path)
  end

  def build_merge_command(temp_files)
    "git merge-file -p #{temp_files[:local].path} #{temp_files[:base].path} " \
      "#{temp_files[:template].path} > #{temp_files[:result].path} 2>/dev/null"
  end

  def handle_merge_result?(merged_content, change)
    if merged_content.include?("<<<<<<<")
      create_conflict_file(merged_content, change)
      false
    else
      apply_merged_content(merged_content, change)
      true
    end
  end

  def create_conflict_file(merged_content, change)
    Thor.new.say "  Merge has conflicts. Creating conflict file for manual resolution.", :yellow
    conflict_path = "#{change[:local_path]}.blueprint_conflict"
    File.write(conflict_path, merged_content)
    Thor.new.say "  Conflict file created: #{conflict_path}", :yellow
  end

  def apply_merged_content(merged_content, change)
    backup_path = "#{change[:local_path]}.blueprint_backup"
    FileUtils.cp(change[:local_path], backup_path)
    File.write(change[:local_path], merged_content)
    Thor.new.say "  Backup created: #{backup_path}", :green
  end

  def cleanup_temp_files(files)
    files.each do |file|
      safe_close_file(file)
      safe_unlink_file(file)
    end
  end

  def safe_close_file(file)
    file.close
  rescue StandardError
    nil
  end

  def safe_unlink_file(file)
    file.unlink
  rescue StandardError
    nil
  end

  def find_previous_template_version(file)
    # For now, try to use the local file as the base if it was generated from a template
    # In the future, we could store previous template versions
    tracked = @templates[file]
    return nil unless tracked

    # Use the current local file as the base (assuming it was from the previous template)
    Rails.root.join(file) if Rails.root.join(file).exist?
  end

  def calculate_checksum(file_path)
    Digest::SHA256.file(file_path).hexdigest
  end

  def blueprint_version
    version_file = Rails.root.join("VERSION_BASIC")
    File.exist?(version_file) ? File.read(version_file).strip : "unknown"
  end

  def load_tracking_data
    return {} unless File.exist?(TRACKING_FILE)

    YAML.load_file(TRACKING_FILE) || {}
  end

  def save_tracking_data
    File.write(TRACKING_FILE, @templates.to_yaml)
  end
end

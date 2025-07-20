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
  task :check_templates => :environment do
    require "digest"
    require "yaml"
    require "diffy"
    
    tracker = TemplateTracker.new
    
    unless tracker.tracking_initialized?
      Thor.new.say "Template tracking not initialized!", :yellow
      Thor.new.say "Run 'rails blueprint:init_template_tracking' to enable template update detection.", :yellow
      Thor.new.say "This will create a baseline for tracking future template changes.", :cyan
    else
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
        
        if Thor.new.yes?("\nWould you like to review and apply updates? (y/n)")
          tracker.apply_updates(changes)
        end
      end
    end
  end

  desc "Force update all templates (creates backups)"
  task :update_templates => :environment do
    tracker = TemplateTracker.new
    
    if !tracker.tracking_initialized?
      Thor.new.say "Template tracking not initialized!", :yellow
      Thor.new.say "Initializing template tracking now...", :cyan
      tracker.save_all_templates
    end
    
    tracker.force_update_all
  end

  desc "Initialize template tracking (only needed for projects created before template tracking was added)"
  task :init_template_tracking => :environment do
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
        checksum: calculate_checksum(template_path),
        version: blueprint_version,
        updated_at: Time.current.to_s
      }
    end
    save_tracking_data
  end

  def check_for_updates
    changes = []
    
    TEMPLATE_FILES.each do |file|
      template_path = Rails.root.join("#{file}.template")
      local_path = Rails.root.join(file)
      
      next unless File.exist?(template_path)
      
      current_checksum = calculate_checksum(template_path)
      tracked = @templates[file]
      
      if tracked.nil?
        changes << { file:, status: :new, template_path:, local_path: }
      elsif tracked[:checksum] != current_checksum
        has_local_changes = File.exist?(local_path) && 
                           !FileUtils.identical?(template_path, local_path)
        changes << { 
          file:, 
          status: :modified, 
          template_path:, 
          local_path:,
          has_local_changes:,
          old_checksum: tracked[:checksum],
          new_checksum: current_checksum
        }
      end
    end
    
    changes
  end

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
        checksum: calculate_checksum(change[:template_path]),
        version: blueprint_version,
        updated_at: Time.current.to_s
      }
    end
    
    save_tracking_data
  end

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

  private

  def handle_merge_conflict(change)
    diff = Diffy::Diff.new(
      File.read(change[:local_path]), 
      File.read(change[:template_path]),
      context: 3
    )
    
    Thor.new.say "  Diff:", :yellow
    puts diff.to_s(:color)
    
    options = {
      "1" => "Keep local version",
      "2" => "Use template version", 
      "3" => "View full diff",
      "4" => "Auto-merge (attempt three-way merge)",
      "5" => "Create .merge file for manual resolution",
      "6" => "Skip this file"
    }
    
    options.each { |k, v| Thor.new.say "  #{k}) #{v}" }
    choice = Thor.new.ask("  Choose option:")
    
    case choice
    when "1"
      Thor.new.say "  Keeping local version", :green
    when "2"
      backup_path = "#{change[:local_path]}.blueprint_backup"
      FileUtils.cp(change[:local_path], backup_path)
      FileUtils.cp(change[:template_path], change[:local_path])
      Thor.new.say "  Updated to template version (backup: #{backup_path})", :green
    when "3"
      puts diff.to_s(:text)
      handle_merge_conflict(change) # Recurse to show options again
    when "4"
      # Attempt automatic three-way merge
      if attempt_auto_merge(change)
        Thor.new.say "  Successfully auto-merged changes!", :green
      else
        Thor.new.say "  Auto-merge failed, please choose another option", :red
        handle_merge_conflict(change)
      end
    when "5"
      merge_path = "#{change[:local_path]}.blueprint_merge"
      File.write(merge_path, <<~MERGE)
        <<<<<<< LOCAL VERSION
        #{File.read(change[:local_path])}
        =======
        #{File.read(change[:template_path])}
        >>>>>>> TEMPLATE VERSION
      MERGE
      Thor.new.say "  Created merge file: #{merge_path}", :yellow
    when "6"
      Thor.new.say "  Skipped", :yellow
      return
    else
      handle_merge_conflict(change) # Invalid choice, try again
    end
  end

  def attempt_auto_merge(change)
    # Find the previous template version for three-way merge
    old_template_path = find_previous_template_version(change[:file])
    
    return false unless old_template_path
    
    require "tempfile"
    
    # Create temporary files for the merge
    base_file = Tempfile.new("base")
    local_file = Tempfile.new("local")
    template_file = Tempfile.new("template")
    result_file = Tempfile.new("result")
    
    begin
      # Write content to temp files
      base_file.write(File.read(old_template_path))
      local_file.write(File.read(change[:local_path]))
      template_file.write(File.read(change[:template_path]))
      
      [base_file, local_file, template_file].each(&:close)
      
      # Attempt three-way merge using git merge-file
      merge_cmd = "git merge-file -p #{local_file.path} #{base_file.path} #{template_file.path} > #{result_file.path} 2>/dev/null"
      merge_status = system(merge_cmd)
      
      if merge_status || $?.exitstatus == 1 # Exit status 1 means conflicts but merge completed
        merged_content = File.read(result_file.path)
        
        # Check if there are merge conflicts
        if merged_content.include?("<<<<<<<")
          Thor.new.say "  Merge has conflicts. Creating conflict file for manual resolution.", :yellow
          conflict_path = "#{change[:local_path]}.blueprint_conflict"
          File.write(conflict_path, merged_content)
          Thor.new.say "  Conflict file created: #{conflict_path}", :yellow
          return false
        else
          # Success! Apply the merged content
          backup_path = "#{change[:local_path]}.blueprint_backup"
          FileUtils.cp(change[:local_path], backup_path)
          File.write(change[:local_path], merged_content)
          Thor.new.say "  Backup created: #{backup_path}", :green
          return true
        end
      else
        return false
      end
    ensure
      [base_file, local_file, template_file, result_file].each do |file|
        file.close rescue nil
        file.unlink rescue nil
      end
    end
  end

  def find_previous_template_version(file)
    # For now, try to use the local file as the base if it was generated from a template
    # In the future, we could store previous template versions
    tracked = @templates[file]
    return nil unless tracked
    
    # Use the current local file as the base (assuming it was from the previous template)
    Rails.root.join(file) if File.exist?(Rails.root.join(file))
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

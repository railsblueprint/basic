class HealthController < ApplicationController
  def show
    render json: {
      status:       "ok",
      version:      version_info,
      git_revision: git_revision,
      timestamp:    Time.current.iso8601
    }
  end

  private

  def version_info
    versions = {}

    # Read all VERSION_* files in the root directory
    Rails.root.glob("VERSION_*").each do |file|
      edition = File.basename(file).gsub("VERSION_", "").downcase
      versions[edition] = File.read(file).strip
    end

    versions
  end

  def git_revision
    if Rails.env.development?
      # In development, try to get git revision from git command
      begin
        `git rev-parse HEAD`.strip
      rescue StandardError
        "unknown"
      end
    else
      # In production, read from .mina_git_revision file created by Mina
      revision_file = Rails.root.join(".mina_git_revision")
      if File.exist?(revision_file)
        File.read(revision_file).strip
      else
        "unknown"
      end
    end
  end
end

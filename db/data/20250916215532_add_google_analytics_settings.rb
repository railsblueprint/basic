# frozen_string_literal: true

class AddGoogleAnalyticsSettings < ActiveRecord::Migration[8.0]
  def up
    # Create Google Analytics section
    Setting.find_or_create_by(
      key:  "google_analytics_section",
      type: "section"
    ) do |s|
      s.description = "Google Analytics tracking configuration"
      s.value = nil
    end

    # Add Google Analytics ID setting with empty string
    Setting.find_or_create_by(
      key:  "google_analytics.id",
      type: "string"
    ) do |s|
      s.description = "Google Analytics measurement ID (G-XXXXXXXXXX)"
      s.value = ""
    end

    # Add enabled flag - disabled by default
    Setting.find_or_create_by(
      key:  "google_analytics.enabled",
      type: "boolean"
    ) do |s|
      s.description = "Enable Google Analytics tracking"
      s.value = "false"
    end
  end

  def down
    Setting.where("key LIKE ?", "google_analytics%").destroy_all
    Setting.where(key: "google_analytics_section").destroy_all
  end
end
